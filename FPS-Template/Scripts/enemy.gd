class_name Enemy
extends Node

var health: Health
@export var health_res: HealthRes
@onready var auto_heal_timer: Timer = $AutoHealTimer


func _ready() -> void:
	health_setup()


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate)
	#player_ui.set_health(health.curr_health, health.max_health)
	health.damage_taken.connect(_on_damage_taken)
	health.dead.connect(_on_death)


func _on_damage_taken():
	if auto_heal_timer != null and health_res.is_auto_heal:
		auto_heal_timer.start()
	

func _on_auto_heal_timeout():
	health._start_healing()
	if health.curr_health >= health.max_health:
		auto_heal_timer.stop()


func _on_death():
	queue_free()



func on_ground_pound():
	health._take_damage(100.0)
