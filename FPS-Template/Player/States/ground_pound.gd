extends PlayerState

var start_pos: Vector3

func enter(previous_state_path: String, data := {}) -> void:
	start_pos = player.position


func physics_update(delta: float) -> void:
	player.movement.ground_pound()
	player.gp_cast.force_shapecast_update()
	if player.gp_cast.is_colliding():
		for i in player.gp_cast.get_collision_count():
			var collider = player.gp_cast.get_collider(i)
			if collider and collider.has_method("on_ground_pound"):
				collider.on_ground_pound()
				finished.emit(JUMPING)
				break
		
	if player.state_wall_run():
		finished.emit(WALL_RUN)
	if player.state_dash():
		finished.emit(DASH)
	if player.state_jump():
		player.d_jump_count += 1
		finished.emit(JUMPING)
	if player.is_on_floor():
		finished.emit(IDLE)


func exit() -> void:
	player.curr_gp_dist = start_pos.distance_to(player.position)
	player.reset_air_movement()
