class_name interact_info extends Node


enum InteractType {
	PICK_UP,
	INTERACT
}


@export_category("Pick Up")
@export var item_path: String
@export var interact_type: InteractType
@export var equipable: bool
