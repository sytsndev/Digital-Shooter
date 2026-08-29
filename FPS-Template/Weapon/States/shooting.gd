extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	w.firing = true
	w.try_fire_weapon()

func update(_delta: float) -> void:
	if w.shooting_state():
		w.try_fire_weapon()
	if !Input.is_action_pressed("shoot"):
		w.firing = false
	if w.current_weapon.current_ammo == 0 and w.current_weapon.reserve_ammo != 0 or w.reload_state():
		finished.emit(RELOADING)
	if w.swapping_state():
		finished.emit(SWAPPING)
	if !w.firing:
		finished.emit(IDLE)


func exit() -> void:
	w.firing = false
	pass
