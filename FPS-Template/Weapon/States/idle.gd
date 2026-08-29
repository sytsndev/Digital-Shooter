extends WeaponState


func enter(previous_state_path: String, data := {}) -> void:
	pass


func update(_delta: float) -> void:
	if w.reload_state():
		finished.emit(RELOADING)
	if w.shooting_state():
		finished.emit(SHOOTING)
	if w.swapping_state():
		finished.emit(SWAPPING)
