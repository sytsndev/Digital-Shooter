extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	if w.current_weapon.full_auto:
		w.firing = true
	w.try_fire_weapon()

func update(_delta: float) -> void:
	if (w.current_weapon.current_ammo == 0 and w.current_weapon.reserve_ammo != 0) or w.reload_state():
		finished.emit(RELOADING)
	elif w.shooting_state():
		w.try_fire_weapon()
	elif !Input.is_action_pressed("shoot"):
		w.firing = false
	elif w.swapping_state():
		finished.emit(SWAPPING)
	elif !w.firing:
		finished.emit(IDLE)


func exit() -> void:
	w.firing = false
	pass
