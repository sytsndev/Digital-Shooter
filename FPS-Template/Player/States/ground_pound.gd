extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
func physics_update(delta: float) -> void:
	
	if player.player_res.movement_type == MovementType.FLOATY:
		player.movement.ground_pound()
		
	if player.state_wall_run():
		finished.emit(WALL_RUN)
	if player.state_dash():
		finished.emit(DASH)
	if player.state_jump():
		player.d_jump_count += 1
		finished.emit(JUMPING)
	if player.is_on_floor():
		finished.emit(IDLE)
