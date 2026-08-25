extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	print("test")


func update(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		print("SHOOT")
