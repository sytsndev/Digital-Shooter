class_name WeaponState extends State

const IDLE = "Idle"

var player: WeaponManager

func _ready() -> void:
	await owner.ready
	player = owner as WeaponManager
	assert(player != null, "The WeaponState state type must be used only in the player scene. It needs the owner to be a WeaponManager node.")
