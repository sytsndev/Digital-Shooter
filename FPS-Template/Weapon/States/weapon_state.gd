class_name WeaponState extends State

const IDLE = "Idle"
const SHOOTING = "Shooting"
const RELOADING = "Reloading"
const AIMING = "Aiming"

var w: WeaponManager
var p_res: PlayerResource

func _ready() -> void:
	await owner.ready
	w = owner as WeaponManager
	p_res = p.player_stats
	assert(p != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
