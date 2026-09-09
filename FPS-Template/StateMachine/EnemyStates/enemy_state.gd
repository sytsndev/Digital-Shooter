class_name EnemyState
extends State

const IDLE = "Idle"
const SEEK = "Seek"
const JUMPING = "Jumping"
const FALLING = "Falling"
const SPRINT = "Sprint"
const DOUBLE_JUMP = "DoubleJump"
const DASH = "Dash"
const SLIDING = "Sliding"
const WALL_RUN = "WallRun"
const GROUND_POUND = "GroundPound"

enum MovementType { 
	WISH_DIR,
	FLOATY,
	MOMENTUM
	}

var enemy: Enemy

func _ready() -> void:
	await owner.ready
	enemy = owner as Enemy
	assert(enemy != null, "The EnemyState state type must be used only in the player scene. It needs the owner to be a Enemy node.")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
