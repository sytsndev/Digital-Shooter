extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	#player.animation_player.play("idle")
	
	
func physics_update(_delta: float) -> void:
	enemy.nav_agent.target_position = enemy.player.global_position
	var next_path_pos = enemy.nav_agent.get_next_path_position()
	
	if !enemy.player_in_view:
		finished.emit(IDLE)
