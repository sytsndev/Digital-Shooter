class_name weapon_pickup extends Interactable


@export_category("Pick Up")
@export var item_path: String

@onready var weapon_manager = get_node("/root/World/Player/Neck/CameraSpring/CameraLean/CameraContainer/Camera3D/WeaponManager")


func interact():
	weapon_manager.pick_up_weapon(item_path)
	queue_free()
