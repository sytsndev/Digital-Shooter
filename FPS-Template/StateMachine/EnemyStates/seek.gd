extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	#player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	#if player.player_res.movement_type == MovementType.MOMENTUM:
	enemy.nav_agent.target_position = enemy.player.global_position
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	var direction = enemy.position.direction_to(next_path_pos)
	enemy.movement.move(direction, _delta, enemy.movement_res.speed)
	
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
