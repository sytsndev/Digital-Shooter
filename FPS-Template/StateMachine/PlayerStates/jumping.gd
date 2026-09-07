extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	if previous_state_path == "GroundPound":
		player.movement.jump_move(player.movement.calculate_rebound_impulse(player.curr_gp_dist))
	else:
		player.movement.jump_move(player.player_res.jump_impulse)
	#player.animation_player.play("jump")

func physics_update(delta: float) -> void:
	if player.velocity.y >= 0:
		finished.emit(FALLING)
