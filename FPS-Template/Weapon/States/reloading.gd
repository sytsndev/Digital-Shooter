extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	w.reload_weapon()

func update(_delta: float) -> void:
	
	if w.reload_timer == 0.0:
		if Input.is_action_pressed("shoot"):
			finished.emit(SHOOTING)
		if w.swapping_state():
			finished.emit(SWAPPING)
		finished.emit(IDLE)
