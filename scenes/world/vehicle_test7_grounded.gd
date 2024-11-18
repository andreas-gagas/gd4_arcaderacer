extends Node
@onready var vehicle_root: RigidBody3D = $"../.."
@onready var fsm: Node = $".."

var look_dir : Vector3
var fwd_speed : float
var abs_speed : float

var throttle_input : float
var steering_input : float
var input_drift : bool = false
var turn_vel : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# init look dir
	look_dir = -vehicle_root.global_transform.basis.z;
	look_dir.y = 0
	look_dir = look_dir.normalized()
	pass # Replace with function body.

func fsm_process(delta : float):
	if Input.is_key_pressed(KEY_Q):
		fsm.set_trigger("Grounded->Airborne")
	if Input.is_key_pressed(KEY_ESCAPE):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	throttle_input = Input.get_axis("move_back", "move_forward")
	steering_input = Input.get_axis("move_right", "move_left")
	input_drift = Input.is_action_pressed("jump")
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
	pass

func remap(value, from_min, from_max, to_min, to_max):
	return to_min + (value - from_min) * (to_max - to_min) / (from_min - from_max)
	

func _on_state_machine_player_updated(source: Variant, state: Variant, delta: Variant) -> void:
	#print(source + " : " + state + " : " + str(delta))
	if state == vehicle_root.state_grounded.name:
		if source == "process":
			fsm_process(delta)
		elif source == "physics":
			fsm_physics(delta)
	pass # Replace with function body.


func _on_state_machine_player_entered(to: Variant) -> void:
	print("hello im at grounded")
	pass # Replace with function body.
