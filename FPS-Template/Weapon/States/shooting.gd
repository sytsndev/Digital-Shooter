extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	w.try_fire_weapon()

func update(_delta: float) -> void:
	if !Input.is_action_pressed("action_1"):
		w.firing = false
	if w.current_weapon.current_ammo == 0 and w.current_weapon.reserve_ammo != 0 or w.reload_state():
		finished.emit(RELOADING)
	finished.emit(IDLE)
	
	
