class_name Interact extends Node3D

var weapon_manager: WeaponManager
var parent

func _ready() -> void:
	parent = get_parent()
	weapon_manager = get_node("/root/World/Player/Neck/CameraSpring/CameraLean/CameraContainer/Camera3D/WeaponManager")

func pick_up():
	if parent.equipable:
		weapon_manager.pick_up_weapon(parent.item_path)
		parent.queue_free()
