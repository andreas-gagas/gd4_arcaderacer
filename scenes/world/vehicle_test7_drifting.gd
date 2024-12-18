extends Node
@onready var vehicle_root: RigidBody3D = $"../.."
@onready var fsm: Node = $".."
@onready var first_boost_timer: Timer = $first_boost_timer
@onready var second_boost_timer: Timer = $second_boost_timer

var throttle_input : float
var steering_input : float
var input_drift : bool = false
var turn_vel : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

func fsm_process(delta : float):
	
	if Input.is_action_just_released("jump"):
		fsm.set_trigger("Drifting->Grounded")
	if Input.is_action_just_pressed("escape"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	throttle_input = Input.get_axis("move_back", "move_forward")
	steering_input = Input.get_axis("move_right", "move_left") / 2 # biar gak begitu powerful steeringnya
	input_drift = Input.is_action_pressed("jump")
	#print("throttle : " + str(throttle_input) + " steering: " + str(steering_input) )
	
		
	pass

func fsm_physics(delta : float):

	for spring in vehicle_root.springs:
		if spring != null:
			spring.update_spring(vehicle_root, delta)
		# spin the tires # EFFECTS ONLY
		#spring._spin_tires(abs_speed, throttle_input, top_speed_fwd, delta)
		pass
	
	
	# ---------- PASTED CODE STARTS HERE
	var look_dir = -vehicle_root.global_transform.basis.z
	look_dir.y = 0
	look_dir = look_dir.normalized()

	var grip_dir = -vehicle_root.global_transform.basis.x
	grip_dir.y = 0
	grip_dir = grip_dir.normalized()

	var car_vel = vehicle_root.linear_velocity
	var fwd_speed = look_dir.dot(car_vel)
	var abs_speed = abs(fwd_speed)
	var top_speed = vehicle_root.top_speed_fwd if fwd_speed >= 0 else vehicle_root.top_speed_back
	var abs_normalized_speed = abs_speed / top_speed

	# override
	var on_ground = true

	if on_ground:
		# Force: fwd/back movement
		var goal_speed = top_speed * throttle_input
		var goal_accel = 10.0  # Dummy value for example
		goal_accel = vehicle_root.acceleration_fwd if fwd_speed >= 0 else vehicle_root.braking_decel
		var instant_accel = (goal_speed - fwd_speed) / delta
		var accel = clamp(instant_accel, -goal_accel, goal_accel)
		vehicle_root.apply_central_force(look_dir * accel * vehicle_root.mass * vehicle_root.force_responsiveness)
		
		# Steering
		#var max_turn_speed = 1.0  # Dummy value for max turn speed
		#print("fwd_speed: " + str(fwd_speed))
		var goal_turn_speed
		if (fwd_speed < 0):
			goal_turn_speed = vehicle_root.max_turn_speed * -steering_input
		else:
			goal_turn_speed = vehicle_root.max_turn_speed * steering_input
		turn_vel = move_toward(turn_vel, goal_turn_speed, vehicle_root.turn_accel * delta)
		#print("turn_vel : " + str(turn_vel) + " angular vel: " + str(angular_velocity) + " lin_vel : " + str(linear_velocity))
		vehicle_root.rotate_y(deg_to_rad(turn_vel) * delta)
		
		if is_equal_approx(steering_input, 0.0):
			
			pass
		else:
			#var new_direction = -global_transform.basis.z + (linear_velocity + (-linear_velocity / 1.1))
			#linear_velocity = new_direction
			pass
			
		# Grip force
		var grip_vel = grip_dir.dot(car_vel)
		var goal_grip_vel = 0.0
		instant_accel = (goal_grip_vel - grip_vel) / delta
		vehicle_root.apply_central_force(grip_dir * instant_accel * vehicle_root.mass * vehicle_root.force_responsiveness)
		# ---------- PASTED CODE ENDS HERE
		
		## drift code?
		#if vehicle_root.drift_dir == vehicle_root.drift_direction.RIGHT:
			#vehicle_root.apply_torque(Vector3.UP * 45 * (vehicle_root.force_responsiveness * 1.5))
		#elif vehicle_root.drift_dir == vehicle_root.drift_direction.LEFT:
			#vehicle_root.apply_torque(Vector3.UP * -45 * (vehicle_root.force_responsiveness * 1.5))
		
		apply_drift_force()
	pass
	
func apply_drift_force():
	var loc_drift_dir = 0
	if vehicle_root.drift_dir == vehicle_root.drift_direction.RIGHT:
		loc_drift_dir = 1
	elif vehicle_root.drift_dir == vehicle_root.drift_direction.LEFT:
		loc_drift_dir = -1
		
	var drift_force = (loc_drift_dir) * vehicle_root.linear_velocity.length() / vehicle_root.top_speed_fwd
	drift_force *= vehicle_root.drift_strength
	
	vehicle_root.apply_torque(Vector3.UP * drift_force)

	var grip_dir = -vehicle_root.global_transform.basis.x
	grip_dir.y = 0
	grip_dir = grip_dir.normalized()
	
	var adjusted_grip_force = max(0, 1 - abs(drift_force))
	vehicle_root.apply_central_force(grip_dir * adjusted_grip_force)

func remap(value, from_min, from_max, to_min, to_max):
	return to_min + (value - from_min) * (to_max - to_min) / (from_min - from_max)

func first_boost_timer_timeout():
	# add boost duration
	vehicle_root.remaining_boost_duration += vehicle_root.first_boost_duration
	# change drift particle
	vehicle_root.drift_particles.emitting = false
	vehicle_root.boost1_drift_particles.emitting = true
	vehicle_root.boost2_drift_particles.emitting = false
	print("first boot reqs matched! remaining_boost_duration: " + str(vehicle_root.remaining_boost_duration))
	pass

func second_boost_timer_timeout():
	# add boost duration
	vehicle_root.remaining_boost_duration += vehicle_root.second_boost_duration
	# change drift particle
	vehicle_root.drift_particles.emitting = false
	vehicle_root.boost1_drift_particles.emitting = false
	vehicle_root.boost2_drift_particles.emitting = true
	print("second boot reqs matched! remaining_boost_duration: " + str(vehicle_root.remaining_boost_duration))
	pass

func _on_state_machine_player_updated(source: Variant, state: Variant, delta: Variant) -> void:
	#print(source + " : " + state + " : " + str(delta))
	if state == vehicle_root.state_drifting.name:
		if source == "process":
			fsm_process(delta)
		elif source == "physics":
			fsm_physics(delta)
	pass # Replace with function body.

var mesh_turn_tween 
func _on_state_machine_player_transited(from: Variant, to: Variant) -> void:
	
	# ON STATE ENTER
	if to == vehicle_root.state_drifting.name:
		GamepadControllerManager.start_controller_vibration(1,2,1)
		#print(str(vehicle_root.drift_dir))
		# set & tween mesh rotation
		if vehicle_root.drift_dir == vehicle_root.drift_direction.RIGHT:
			if mesh_turn_tween:
				mesh_turn_tween.kill()
			mesh_turn_tween = get_tree().create_tween()
			var target_rotation = Vector3(deg_to_rad(0), deg_to_rad(40), deg_to_rad(-15))
			mesh_turn_tween.tween_property(vehicle_root.car_mesh_rotation_offset, "rotation", target_rotation, .25).from_current()
		elif vehicle_root.drift_dir == vehicle_root.drift_direction.LEFT:
			if mesh_turn_tween:
				mesh_turn_tween.kill()
			mesh_turn_tween = get_tree().create_tween()
			var target_rotation = Vector3(deg_to_rad(0), deg_to_rad(-40), deg_to_rad(15))
			mesh_turn_tween.tween_property(vehicle_root.car_mesh_rotation_offset, "rotation", target_rotation, .25).from_current()
			pass

		# start emitting drift particles, stop boost1 & boost2 drift particles
		vehicle_root.drift_particles.emitting = true
		vehicle_root.boost1_drift_particles.emitting = false
		vehicle_root.boost2_drift_particles.emitting = false
		
		# start drift timers
		# init & start drift timer
		first_boost_timer.wait_time = vehicle_root.minimum_drift_duration_for_first_boost
		first_boost_timer.start()
		second_boost_timer.wait_time = vehicle_root.minimum_drift_duration_for_second_boost
		second_boost_timer.start()
		pass
	
	# ON STATE EXIT
	if from == vehicle_root.state_drifting.name:
		# revert drift physics
		vehicle_root.angular_velocity = Vector3.ZERO
		
		# revert car_mesh rotation by tweening 
		if mesh_turn_tween:
			mesh_turn_tween.kill()
		mesh_turn_tween = get_tree().create_tween()
		var target_rotation = Vector3(deg_to_rad(0), deg_to_rad(0), deg_to_rad(0))
		mesh_turn_tween.tween_property(vehicle_root.car_mesh_rotation_offset, "rotation", target_rotation, .25).from_current()

		# revert drift_dir parameter
		#print("Reverting drift_dir!")
		vehicle_root.drift_dir == vehicle_root.drift_direction.NONE
		
		# stop emitting all drift particles
		vehicle_root.drift_particles.emitting = false
		vehicle_root.boost1_drift_particles.emitting = false
		vehicle_root.boost2_drift_particles.emitting = false
		
		# stop drift timers
		first_boost_timer.stop()
		second_boost_timer.stop()
		pass
	pass # Replace with function body.
