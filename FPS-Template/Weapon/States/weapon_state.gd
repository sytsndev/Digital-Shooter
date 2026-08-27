class_name WeaponState extends State

const IDLE = "Idle"
const SHOOTING = "Shooting"
const RELOADING = "Reloading"
const AIMING = "Aiming"

var w: WeaponManager

func _ready() -> void:
	await owner.ready
	w = owner as WeaponManager
	assert(w != null, "The WeaponState state type must be used only in the weapon scene. It needs the owner to be a Weapon node.")


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("shoot"):
		w.firing = false
