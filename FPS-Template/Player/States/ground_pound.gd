extends PlayerState

var start_pos: Vector3

func enter(previous_state_path: String, data := {}) -> void:
	start_pos = player.position


func physics_update(delta: float) -> void:
	if player.player_res.movement_type == MovementType.FLOATY:
		player.movement.ground_pound()
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision == null:
			continue
		var collider = collision.get_collider()
		print(collider) 
		if collider.has_method("on_ground_pound"):
			collider.on_ground_pound()
			finished.emit(JUMPING)
		
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
