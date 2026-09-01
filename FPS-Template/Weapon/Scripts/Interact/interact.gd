class_name Interact
extends Node

var parent


func _ready() -> void:
	parent = get_parent()


func interact():
	parent.interact()
