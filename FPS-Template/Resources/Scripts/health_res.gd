class_name HealthRes extends Resource

@export_category("Toggles")
@export var god_mode: bool

@export_category("Stats")
@export var max_health: float
@export var min_health: float
@export var heal_rate: float
@export var full_heal_time: float

@export_category("Auto Heal Timer")
@export var is_auto_heal: float = false
@export var auto_heal_delay: float
@export var is_one_shot: bool
@export var is_auto_start: bool
