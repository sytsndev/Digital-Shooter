extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	print("test")


func update(_delta: float) -> void:
	if w.reload_state():
		finished.emit(RELOADING)
	if (Input.is_action_just_pressed("action_1") or w.firing) and w.fire_cooldown <= 0.0:
		finished.emit(SHOOTING)
