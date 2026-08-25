class_name Movement
extends Node

@export var player: Player

#DASHING
var is_dashing := false
var dash_dir := Vector3.ZERO
var dash_timer := 0.0

var is_sliding := false
var slide_dir := Vector3.ZERO
var slide_timer := 0.0
var slide_speed: float = 0.0

func stop_move(delta: float):
	var prev_velocity := player.velocity
	
	player.velocity.y += player.player_res.gravity * delta
	player.velocity.x = move_toward(player.velocity.x, 0, player.player_res.speed)
	player.velocity.z = move_toward(player.velocity.z, 0, player.player_res.speed)
	player.move_and_slide()
	var acceleration := (player.velocity - prev_velocity) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)

func fall_move(direction: Vector3, delta: float):
	var prev_velocity := player.velocity
	if direction:
		player.velocity.x = direction.x * player.player_res.speed
		player.velocity.z = direction.z * player.player_res.speed 

	if player.velocity.y > 0.0:
		player.velocity.y += player.player_res.jump_gravity * delta
	else:
		player.velocity.y += player.player_res.gravity * delta
	player.move_and_slide()
	var acceleration := (player.velocity - prev_velocity) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)

func jump_move():
	player.velocity.y = player.player_res.jump_impulse
	player.move_and_slide()
	


func sprint(direction: Vector3, delta: float):
	var prev_velocity := player.velocity
	if direction:
		player.velocity.x = direction.x * player.player_res.sprint_speed
		player.velocity.z = direction.z * player.player_res.sprint_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.player_res.sprint_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.player_res.sprint_speed)

	player.move_and_slide()
	var acceleration := (player.velocity - prev_velocity) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func run(direction: Vector3, delta: float):
	var prev_velocity := player.velocity
	if direction:
		player.velocity.x = direction.x * player.get_speed()
		player.velocity.z = direction.z * player.get_speed()
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.get_speed())
		player.velocity.z = move_toward(player.velocity.z, 0, player.get_speed())
	player.move_and_slide()
	var acceleration := (player.velocity - prev_velocity) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func move(direction: Vector3, delta: float, speed: float):
	var prev_velocity := player.velocity
	if direction:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)
	player.move_and_slide()
	var acceleration := (player.velocity - prev_velocity) / delta
	
	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func start_dash(direction: Vector3) -> void:
	dash_dir = direction
	if direction == Vector3.ZERO:
		return
	
	is_dashing = true
	dash_dir = direction.normalized()
	dash_timer = player.player_res.dash_time
	player.velocity.y = 0
	player.velocity = dash_dir * player.player_res.dash_impulse
	player.dash_count += 1
	if player.player_res.dash_reset_jump:
		player.d_jump_count = 0

func dash_move(delta: float):
	var prev_velocity := player.velocity
	
	if not is_dashing:
		return

	player.velocity = dash_dir * player.player_res.dash_impulse
	player.move_and_slide()

	dash_timer -= delta
	if dash_timer <= 0.0:
		is_dashing = false
	var acceleration := (player.velocity - prev_velocity) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func start_slide(direction: Vector3) -> void:
	slide_dir = direction
	if direction == Vector3.ZERO:
		return
	
	if player.slide_reset_timer <= 0.0:
		slide_speed = player.player_res.slide_impulse
	elif Input.is_action_pressed("sprint"):
		slide_speed = player.player_res.sprint_speed
	else:
		slide_speed = player.player_res.speed
	
	is_sliding = true
	slide_dir = direction.normalized()
	slide_timer = player.player_res.slide_time
	player.velocity.y = 0
	player.velocity = slide_dir * slide_speed


func slide_move(delta: float):
	var prev_velocity := player.velocity
	
	if not is_sliding:
		return
	
	player.velocity = slide_dir * slide_speed

	player.move_and_slide()

	slide_timer -= delta
	if slide_timer <= 0.0:
		is_sliding = false
	var acceleration := (player.velocity - prev_velocity) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func enter_wall_run():
	if player.left_wall_run_rays.all(func(ray): return ray.is_colliding()):
		var wall_normal = player.left_wall_run_rays[0].get_collision_normal()
		return get_wall_info(wall_normal, "Left")
		
	if player.right_wall_run_rays.all(func(ray): return ray.is_colliding()):
		var wall_normal = player.right_wall_run_rays[0].get_collision_normal()
		return get_wall_info(wall_normal, "Right")


func get_wall_info(wall_normal: Vector3, side: String):
	var wall_up = (Vector3.UP - Vector3.UP.project(wall_normal.normalized())).normalized()
	var along_wall: Vector3 = Vector3.UP.cross(wall_normal).normalized()
	var rays: String = ""
	match side:
		"Left":
			for ray in player.left_wall_run_rays:
				var rot = ray.global_rotation
				player.wall_run_container.remove_child(ray)
				player.add_child(ray)
				ray.rotation = rot
				rays = side
		"Right":
			along_wall = -along_wall
			for ray in player.right_wall_run_rays:
				var rot = ray.global_rotation
				player.wall_run_container.remove_child(ray)
				player.add_child(ray)
				ray.rotation = rot
				rays = side
	return {
		"wall_normal": wall_normal,
		"wall_up": wall_up,
		"run_dir": along_wall,
		"rays": rays
	}


func wish_dir_move(delta: float, input_dir: Vector2, speed: float):
	var prev_velocity := player.velocity
	
	var wish_dir = player.neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var cur_speed_in_wish_dir = player.velocity.dot(wish_dir)
	var add_speed_till_cap = speed - cur_speed_in_wish_dir

	if add_speed_till_cap > 0:
		var accel_speed = player.player_res.air_accel * delta * speed
		accel_speed = min(accel_speed, add_speed_till_cap)
		player.velocity += accel_speed * wish_dir

	var control = max(player.velocity.length(), player.player_res.ground_decel)
	var drop = control * player.player_res.ground_friction * delta
	var new_speed = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		new_speed /= player.velocity.length()
	player.velocity *= new_speed
	
	player.move_and_slide()
	
	var acceleration := (player.velocity - prev_velocity) / delta
	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func air_wish_dir_move(delta: float, input_dir: Vector2):
	var prev_velocity := player.velocity
	
	player.velocity.y += player.player_res.gravity * delta
	var wish_dir = player.neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	var cur_speed_in_wish_dir = player.velocity.dot(wish_dir)
	var capped_speed = min((player.player_res.air_move_speed * wish_dir).length(), player.player_res.air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = player.player_res.air_accel * player.player_res.air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		player.velocity += accel_speed * wish_dir
	
	player.move_and_slide()
	
	var acceleration := (player.velocity - prev_velocity) / delta
	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func stop_player(delta: float):
	var prev_velocity := player.velocity
	
	player.velocity.y += player.player_res.gravity * delta
	player.velocity.x = move_toward(player.velocity.x, 0, player.player_res.ground_decel)
	player.velocity.z = move_toward(player.velocity.z, 0, player.player_res.ground_decel)
	player.move_and_slide()
	#climbing_ray_look_at()
	
	var acceleration := (player.velocity - prev_velocity) / delta
	if player.player_res.c_lean:
		player.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func momentum_move(delta: float, input_dir: Vector2, max_speed: float) -> void:
	var previous_horizontal_velocity := Vector3(
		player.velocity.x,
		0.0,
		player.velocity.z
	)

	var wish_dir := get_wish_dir(input_dir)

	if player.is_on_floor():
		momentum_ground_move(delta, wish_dir, max_speed)
	else:
		momentum_air_move(delta, wish_dir, max_speed)

	player.move_and_slide()

	var current_horizontal_velocity := Vector3(
		player.velocity.x,
		0.0,
		player.velocity.z
	)

	var horizontal_acceleration := (
		current_horizontal_velocity - previous_horizontal_velocity
	) / delta

	if player.player_res.c_lean:
		player.camera_lean.update_lean(
			delta,
			horizontal_acceleration,
			Vector3.UP
		)


func momentum_ground_move(
	delta: float,
	wish_dir: Vector3,
	max_speed: float
) -> void:
	var horizontal_velocity := Vector3(
		player.velocity.x,
		0.0,
		player.velocity.z
	)

	if wish_dir.length_squared() == 0.0:
		var current_speed: float = horizontal_velocity.length()

		if current_speed > 0.001:
			var new_speed: float = maxf(
				current_speed - player.player_res.m_ground_friction * delta,
				0.0
			)

			horizontal_velocity *= new_speed / current_speed
		else:
			horizontal_velocity = Vector3.ZERO
	else:
		var target_velocity := wish_dir * max_speed
		var acceleration: float = player.player_res.m_ground_accel

		if horizontal_velocity.length_squared() > 0.001:
			var velocity_direction := horizontal_velocity.normalized()

			if velocity_direction.dot(wish_dir) < 0.0:
				acceleration = player.player_res.m_ground_brake_accel

		horizontal_velocity = horizontal_velocity.move_toward(
			target_velocity,
			acceleration * delta
		)

	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.z


func momentum_air_move(
	delta: float,
	wish_dir: Vector3,
	max_speed: float
) -> void:
	player.velocity.y += player.player_res.gravity * delta

	var horizontal_velocity := Vector3(
		player.velocity.x,
		0.0,
		player.velocity.z
	)

	if wish_dir.length_squared() > 0.0:
		var current_speed_in_wish_dir: float = horizontal_velocity.dot(wish_dir)
		var remaining_speed: float = max_speed - current_speed_in_wish_dir

		if remaining_speed > 0.0:
			var acceleration: float = minf(
				player.player_res.m_air_accel * delta,
				remaining_speed
			)

			horizontal_velocity += wish_dir * acceleration

	var air_speed_cap := max_speed * player.player_res.m_air_speed_multiplier

	if horizontal_velocity.length() > air_speed_cap:
		horizontal_velocity = horizontal_velocity.limit_length(air_speed_cap)

	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.z


func get_wish_dir(input_dir: Vector2) -> Vector3:
	var forward := player.neck.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := player.neck.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()

	var wish_dir := right * input_dir.x + forward * input_dir.y

	if wish_dir.length_squared() > 0.0:
		wish_dir = wish_dir.normalized()

	return wish_dir
