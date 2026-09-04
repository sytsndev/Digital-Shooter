class_name Interactable extends Node3D

enum InteractType {
	AUTO_TRIGGER,
	MANUAL_TRIGGER,
	INTERACT_TRIGGER
}

@export var interact_type: InteractType

func interact():
	pass
