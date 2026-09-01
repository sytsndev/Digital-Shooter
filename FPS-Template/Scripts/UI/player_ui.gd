class_name PlayerUI
extends Control


@export var weapon_manager: WeaponManager
@export var player: Player


@onready var ammo_label: RichTextLabel = %AmmoLabel
@onready var health_label: RichTextLabel = %HealthLabel


func _process(delta: float) -> void:
	ammo_label.text = str(weapon_manager.current_weapon.current_ammo) + "/" + str(weapon_manager.current_weapon.reserve_ammo)
	health_label.text = str(player.health.curr_health)
