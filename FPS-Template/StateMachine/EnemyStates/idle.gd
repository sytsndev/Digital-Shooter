extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	print("idle ", enemy.name)
	#player.animation_player.play("idle")

	
