extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	#player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	pass
	#if player.player_res.movement_type == MovementType.MOMENTUM:
	enemy.movement.stop_character_move(_delta)
	if enemy.player_in_view:
		finished.emit(SEEK)
	#else:
		#player.movement.stop_move(_delta)
#
	#if not player.is_on_floor():
		#finished.emit(FALLING)
	#elif player.state_jump():
		#finished.emit(JUMPING)
	#elif player.state_sprint():
		#finished.emit(SPRINT)
	#elif player.state_run():
		#finished.emit(RUNNING)
