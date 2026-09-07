extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	if w.firing:
		w.firing = false
	pass

func update(_delta: float) -> void:
	w.swap_weapon(w.swap_slot)
	finished.emit(IDLE)
