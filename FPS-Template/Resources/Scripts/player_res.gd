class_name PlayerResource extends Resource

@export_category("Movement")
@export var move_speed: float
@export var sprint_speed: float
@export var jump_velocity: float
@export var auto_bhop: bool
@export var gravity: float
@export var toggle_sprint: bool

@export_category("Air Movement")
@export var air_cap: float
@export var air_accel: float
@export var air_move_speed: float

@export_category("Ground Movement")
@export var ground_accel: float
@export var ground_decel: float
@export var ground_friction: float

@export_category("Camera Controls")
@export var default_fov: float
@export var sprint_fov: float
@export var lean_rotation: float
@export var lean_time: float
"res://Resources/Weapons/weapon_1.tres"
