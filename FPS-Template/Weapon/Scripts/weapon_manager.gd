extends Node3D
class_name WeaponManager

# --- Weapon slot keys
const SLOT_1 := "slot_1"
const SLOT_2 := "slot_2"

# --- Weapon resources
@onready var weapon_slots := {
	SLOT_1: preload("res://Resources/Weapons/weapon_1.tres"),
	SLOT_2: preload("res://Resources/Weapons/weapon_2.tres")
}
@onready var empty_slot: WeaponResource = preload("res://Resources/Weapons/empty.tres")

# --- UI and state
@export var control: Control
@export var crosshair_ray: RayCast3D
var current_slot_key: String = SLOT_1
var swap_slot: String = ""
var current_weapon: WeaponResource = null
var current_weapon_instance: Node3D = null
var fire_cooldown: float = 0.0
var firing: bool = false
var animation_player: AnimationPlayer
var reloading: bool = false
var reload_timer: float = 0.0

var reload_anim_speed: float

func _ready() -> void:
	equip_weapon(SLOT_1)

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta
		if fire_cooldown <= 0.0:
			fire_cooldown = 0.0
	#print("timer", reload_timer > 0.0)
	if reloading:
		if reload_timer > 0.0:
			reload_timer -= delta
			if reload_timer <= 0.0:
				finish_reload()
				reload_timer = 0.0
				reloading = false
	update_ammo_ui()

	handle_input()

func handle_input():
	if Input.is_action_just_pressed("drop"):
		drop_current_weapon()

func equip_weapon(slot_key: String):
	# Remove current weapon model
	remove_current_weapon_model()
	# Equip new weapon
	current_slot_key = slot_key
	current_weapon = weapon_slots.get(slot_key, empty_slot)
	current_weapon.weapon_slot = slot_key
	if current_weapon.weapon_type != WeaponEnums.WeaponType.EMPTY:
		spawn_weapon_model(current_weapon.weapon_model_in_hands)


func swap_weapon(slot_key: String):
	if slot_key == current_slot_key:
		return
	equip_weapon(slot_key)


func try_fire_weapon():
	if current_weapon.current_ammo > 0:
		if animation_player != null:
			animation_player.stop()
			animation_player.play("shoot")
		if !current_weapon.infite_ammo:
			current_weapon.current_ammo -= 1
		if crosshair_ray.is_colliding():
			try_damage()
		fire_cooldown = current_weapon.fire_rate
		if current_weapon.full_auto and not firing:
			firing = true


func try_damage():
	var collider = crosshair_ray.get_collider()
	if collider.has_method("take_damage"):
		collider.take_damage(current_weapon.damage)


func reload_weapon():
	if not current_weapon:
		return
	if !reloading:
		reload_timer = current_weapon.reload_delay
		reloading = true
		if animation_player != null:
			animation_player.play("reload", -1, reload_anim_speed)


func finish_reload():
	var needed_ammo = current_weapon.max_ammo - current_weapon.current_ammo
	var ammo_to_load = min(needed_ammo, current_weapon.reserve_ammo)
	current_weapon.current_ammo += ammo_to_load
	current_weapon.reserve_ammo -= ammo_to_load
	print("Reloaded: %d, Reserve: %d" % [current_weapon.current_ammo, current_weapon.reserve_ammo])


func drop_current_weapon():
	if not current_weapon or current_weapon.weapon_type == WeaponEnums.WeaponType.EMPTY:
		return
	# Remove from hand
	remove_current_weapon_model()
	# Spawn in world
	spawn_weapon_model(current_weapon.weapon_model_in_world, true)
	# Set slot to empty
	weapon_slots[current_slot_key] = empty_slot
	equip_weapon(current_slot_key)


func pick_up_weapon(resource_path: String):
	var new_weapon: WeaponResource = load(resource_path)
	if not new_weapon:
		print("Failed to load weapon: ", resource_path)
		return

	# 1. If current slot is empty, equip in current hand
	if current_weapon.weapon_type == WeaponEnums.WeaponType.EMPTY:
		weapon_slots[current_slot_key] = new_weapon
		equip_weapon(current_slot_key)
		return

	# 2. If current slot is taken, find first empty slot
	for slot_key in [SLOT_1, SLOT_2]:
		if weapon_slots[slot_key].weapon_type == WeaponEnums.WeaponType.EMPTY:
			weapon_slots[slot_key] = new_weapon
			# Keep current slot equipped
			return

	# 3. If all slots full, drop current slot's weapon and replace
	drop_current_weapon()
	weapon_slots[current_slot_key] = new_weapon
	equip_weapon(current_slot_key)

func remove_current_weapon_model():
	if current_weapon_instance and current_weapon_instance.is_inside_tree():
		current_weapon_instance.queue_free()
		current_weapon_instance = null

func spawn_weapon_model(model_path: String, in_world: bool = false):
	var scene = load(model_path)
	if not scene:
		print("Failed to load model: ", model_path)
		return
	var instance = scene.instantiate()
	if in_world:
		get_tree().root.add_child(instance)
		instance.global_transform.origin = self.global_transform.origin
	else:
		add_child(instance)
		instance.position = Vector3(current_weapon.weapon_position_x, current_weapon.weapon_position_y, current_weapon.weapon_position_z)
		instance.rotation = Vector3(current_weapon.weapon_rotation_x, current_weapon.weapon_rotation_y, current_weapon.weapon_rotation_z)
		current_weapon_instance = instance
	
	var anim_player = instance.find_child("AnimationPlayer")
	if anim_player != null:
		animation_player = anim_player
		setup_animation_times()
	else:
		animation_player = null
	print("Weapon model spawned: ", model_path)


func update_ammo_ui():
	if not control or not current_weapon:
		return
	var ammo_counter = control.get_child(0)
	ammo_counter.set_text("%s/%s | %s" % [
		current_weapon.current_ammo,
		current_weapon.max_ammo,
		current_weapon.reserve_ammo
	])


func setup_animation_times():
	var reload_anim = animation_player.get_animation("reload")
	reload_anim_speed = reload_anim.length / current_weapon.reload_delay


#region State Checks


func reload_state():
	return Input.is_action_just_pressed("reload") and current_weapon.max_ammo != current_weapon.current_ammo and current_weapon.reserve_ammo != 0


func swapping_state():
	swap_slot = ""
	if Input.is_action_just_pressed("weapon_slot_1"):
		swap_slot = SLOT_1
	elif Input.is_action_just_pressed("weapon_slot_2"):
		swap_slot = SLOT_2
	return swap_slot != ""


func shooting_state():
	return (Input.is_action_just_pressed("action_1") or firing) and fire_cooldown <= 0.0
