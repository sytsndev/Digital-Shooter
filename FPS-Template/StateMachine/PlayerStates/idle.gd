extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	#player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	if player.player_res.movement_type == MovementType.MOMENTUM:
		player.movement.momentum_move(_delta, Vector2.ZERO, player.player_res.m_speed)
	else:
		player.movement.stop_move(_delta)

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif player.state_jump():
		finished.emit(JUMPING)
	elif player.state_sprint():
		finished.emit(SPRINT)
	elif player.state_run():
		finished.emit(RUNNING)
