extends RigidBody3D
# damn pls end this suffering (in a good way)
# okay it finally done! (the base); it was studied from wallaber's racing game 

@export var springs : Array[Node3D]
@export var top_speed_fwd : float = 20
@export var top_speed_back : float = 20
@export var force_responsiveness : float = 0.2
@export var turn_accel : float = 360
@export var acceleration_fwd : float = 40
@export var acceleration_back : float = 40
@export var braking_decel : float = 60
@export var max_turn_speed = 60

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
	look_dir = -global_transform.basis.z;
	look_dir.y = 0
	look_dir = look_dir.normalized()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	

	throttle_input = Input.get_axis("move_back", "move_forward")
	steering_input = Input.get_axis("move_right", "move_left")
	input_drift = Input.is_action_pressed("jump")
	pass
	
func _physics_process(delta: float) -> void:
	for spring in springs:
		if spring != null:
			spring.update_spring(self, delta)
		# spin the tires # EFFECTS ONLY
		#spring._spin_tires(abs_speed, throttle_input, top_speed_fwd, delta)
		pass
	
	
	# ---------- PASTED CODE STARTS HERE
	var look_dir = -global_transform.basis.z
	look_dir.y = 0
	look_dir = look_dir.normalized()

	var grip_dir = -global_transform.basis.x
	grip_dir.y = 0
	grip_dir = grip_dir.normalized()

	var car_vel = self.linear_velocity
	var fwd_speed = look_dir.dot(car_vel)
	var abs_speed = abs(fwd_speed)
	var top_speed = top_speed_fwd if fwd_speed >= 0 else top_speed_back
	var abs_normalized_speed = abs_speed / top_speed

	# override
	var on_ground = true

	if on_ground:
		# Force: fwd/back movement
		var goal_speed = top_speed * throttle_input
		var goal_accel = 10.0  # Dummy value for example
		goal_accel = acceleration_fwd if fwd_speed >= 0 else braking_decel
		var instant_accel = (goal_speed - fwd_speed) / delta
		var accel = clamp(instant_accel, -goal_accel, goal_accel)
		self.apply_central_force(look_dir * accel * self.mass * force_responsiveness)
		
		# Steering
		#var max_turn_speed = 1.0  # Dummy value for max turn speed
		print("fwd_speed: " + str(fwd_speed))
		var goal_turn_speed
		if (fwd_speed < 0):
			goal_turn_speed = max_turn_speed * -steering_input
		else:
			goal_turn_speed = max_turn_speed * steering_input
		turn_vel = move_toward(turn_vel, goal_turn_speed, turn_accel * delta)
		#print("turn_vel : " + str(turn_vel) + " angular vel: " + str(angular_velocity) + " lin_vel : " + str(linear_velocity))
		rotate_y(deg_to_rad(turn_vel) * delta)
		
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
		self.apply_central_force(grip_dir * instant_accel * self.mass * force_responsiveness)
		# ---------- PASTED CODE ENDS HERE

func _get_point_velocity(point : Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - to_global(center_of_mass))
	pass

func remap(value, from_min, from_max, to_min, to_max):
	return to_min + (value - from_min) * (to_max - to_min) / (from_min - from_max)
