extends Interactable


@export var connection: String


func interact():
	if can_interact and !is_one_shot:
		print("is interactable")
	elif can_interact and is_one_shot:
		print("Is One Shot")
		can_interact = false
