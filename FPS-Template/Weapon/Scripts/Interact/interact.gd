class_name Interact
extends Node

var parent

@export var is_trigger: bool = false
@export var is_auto_trigger: bool = false

func _ready() -> void:
	parent = get_parent()


func interact():
	parent.interact()
