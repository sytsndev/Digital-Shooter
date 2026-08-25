class_name PlayerUI
extends Control


@export var weapon_manager: WeaponManager

var ammo_label: RichTextLabel


func _ready() -> void:
	ammo_label = %AmmoLabel


func _process(delta: float) -> void:
	ammo_label.text = str(weapon_manager.current_weapon.current_ammo) + "/" + str(weapon_manager.current_weapon.reserve_ammo)
