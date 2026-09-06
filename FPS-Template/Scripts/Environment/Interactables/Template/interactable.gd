class_name Interactable extends Node3D

enum InteractType {
	AUTO_TRIGGER,
	MANUAL_TRIGGER,
	INTERACT_TRIGGER
}

@export var interact_type: InteractType
@export var is_one_shot: bool = false

var can_interact: bool = true


func interact():
	pass
