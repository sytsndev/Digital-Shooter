class_name Player extends CharacterBody3D


@export_category("Reaources")
@export var health_res: HealthRes
@export var player_res: PlayerRes

@export_category("Nodes")
@export var neck: Node3D
@export var camera: Node3D
@export var crouch_shape_cast: ShapeCast3D
@export var gp_cast: ShapeCast3D
@export var collision_shape: CollisionShape3D
@export var player_mesh: MeshInstance3D
@export var movement: Movement
@export var camera_lean: CameraLean
@export var camera_manager: CameraManager
@export var left_wall_run_rays: Array[RayCast3D]
@export var right_wall_run_rays: Array[RayCast3D]
@export var grapple_cast: RayCast3D
@export var interact_ray: RayCast3D
@export var auto_heal_timer: Timer

@onready var wall_run_container: Node3D = $Neck/WallRun

var health: Health

var is_crouching: bool = false
var exiting_crouching: bool = false

var d_jump_count: int = 0
var dash_count: int = 0
var wr_reset_timer: float = 0.0
var slide_reset_timer: float = 0.0
var curr_gp_dist: float = 0.0 # this is holding the value of the height of the players current ground pound

var is_paused: bool = false
var is_dead: bool = false

func _ready() -> void:
	setup()


func _process(delta: float) -> void:
	wall_run_timer(delta)
	slide_timer(delta)
	if interact_ray.is_colliding():
		set_interact()

func set_interact():
	var collider = interact_ray.get_collider()
	var interact = collider.get_node_or_null("Interact")
	if interact != null and Input.is_action_just_pressed("interact"):
		interact.interact()


#region Setup


func setup():
	camera.position = player_res.camera_pos
	grapple_cast.target_position = player_res.grapple_dist
	health_setup()
	time_setup()


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate, health_res.god_mode)
	health.healthType = "Player"
	#player_ui.set_health(health.curr_health, health.max_health)
	health.damage_taken.connect(_on_damage_taken)
	health.dead.connect(_on_death)


func time_setup():
	auto_heal_timer.timeout.connect(_on_auto_heal_timeout)
	auto_heal_timer.wait_time = health_res.auto_heal_delay
	auto_heal_timer.one_shot = health_res.is_one_shot
	auto_heal_timer.autostart = health_res.is_auto_start


#endregion


#region Crouching


func enter_crouch_ground():
	if exiting_crouching:
		return
	is_crouching = true
	collision_shape.scale.y = collision_shape.scale.y / 1.5
	camera.position = player_res.camera_pos / 1.5
	velocity.y += -50.0
	move_and_slide()


func  enter_crouch_air():
	collision_shape.scale.y = collision_shape.scale.y / 1.5
	camera.position = player_res.camera_pos / 1.5
	is_crouching = true


func exit_crouch():
	if movement.is_sliding:
		return
	is_crouching = false
	collision_shape.scale.y = collision_shape.scale.y * 1.5
	camera.position = player_res.camera_pos
	
	exiting_crouching = false


#endregion


#region State Change Checks

func state_jump():
	if !player_res.double_jump and !is_on_floor():
		return false
	if player_res.auto_bhop and Input.is_action_pressed("jump") and is_on_floor():
		return true
	return Input.is_action_just_pressed("jump") and player_res.max_double_jump_count > d_jump_count

func state_run():
	return Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" )or Input.is_action_pressed("move_back")

func state_sprint():
	if !player_res.sprint:
		return false
	return !is_crouching and Input.is_action_pressed("sprint") and (Input.is_action_pressed("move_forward" ))

func state_idle(input_dir: Vector2):
	return is_equal_approx(input_dir.x, 0.0) && is_equal_approx(input_dir.y, 0.0)

func state_slide():
	if !player_res.slide or !player_res.crouch:
		return false
	return Input.is_action_just_pressed("crouch")

func state_dash():
	if !player_res.dash:
		return false
	return Input.is_action_just_pressed("dash") and dash_count < player_res.max_dash_count

func state_wall_run():
	if !player_res.wall_run:
		return false
	return (left_wall_run_rays.all(func(ray): return ray.is_colliding()) or right_wall_run_rays.all(func(ray): return ray.is_colliding())) and wr_reset_timer == 0.0

func state_grapple():
	if !player_res.grapple:
		return false
	return Input.is_action_just_pressed("grapple") and grapple_cast.is_colliding()

func state_ground_pound():
	if !player_res.ground_pound:
		return false
	return Input.is_action_just_pressed("crouch") and !is_on_floor()

#endregion


#region Health


func _on_damage_taken():
	auto_heal_timer.start()
	

func _on_auto_heal_timeout():
	health._start_healing()
	if health.curr_health >= health.max_health:
		auto_heal_timer.stop()


func _on_death():
	is_dead = true

#endregion


func get_speed():
	if is_crouching:
		return player_res.crouch_speed
	else:
		return player_res.speed


func wall_run_timer(delta: float):
	if is_on_floor():
		wr_reset_timer = 0.0
	if wr_reset_timer > 0.0:
		wr_reset_timer -= delta
		if wr_reset_timer <= 0.0:
			wr_reset_timer = 0.0


func slide_timer(delta: float):
	if slide_reset_timer > 0.0:
		slide_reset_timer -= delta
		if slide_reset_timer <= 0.0:
			slide_reset_timer = 0.0


func reset_air_movement(d_jump: bool = true, dash: bool = true):
	if d_jump:
		d_jump_count = 0
	if dash:
		dash_count = 0
