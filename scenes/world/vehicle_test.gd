extends RigidBody3D
@onready var car_mesh = $"CarMesh Anchor"
#@onready var body_mesh = $CarMesh/body
@onready var ground_ray = $RayCast3D
#@onready var right_wheel = $"CarMesh/wheel-front-right"
#@onready var left_wheel = $"CarMesh/wheel-front-left"

@export var carResetPosition : Node3D

#the default settings below is ONLY configured for Mass 5kg, friction 5, rough enabled, bounce 0, absorbent disabled 


# Where to place the car mesh relative to the sphere
@export var sphere_offset = Vector3.DOWN
@export var top_speed = 10
@export var drift_top_speed = 60
# Engine power
@export var acceleration = 45
@export var drift_acceleration = 75
# Turn amount, in degrees
@export var steering = 36
@export var drift_steering = 18.0
# How quickly the car turns
@export var turn_speed = 4.0
# Below this speed, the car doesn't turn
@export var turn_stop_limit = 0.75
@export var body_tilt = 35
@export var isGrounded : bool


# Variables for input values
var speed_input = 0
var turn_input = 0

var is_drifting : bool = false

#func _ready():
#	ground_ray.add_exception(self)
	
func _physics_process(delta):
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		if turn_input > 0 and turn_input < 0:
			apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
		else:
			apply_central_force(-car_mesh.global_transform.basis.z * 2.5 * speed_input)
			
		# clamp velocity
		linear_velocity = clamp_velocity(linear_velocity, top_speed)
		#print("(DEBUG) speed: " + str(linear_velocity))
		pass


func _process(delta):
	# respawn
	if Input.is_key_pressed(KEY_R):
		self.position = carResetPosition.position
		linear_velocity = Vector3.ZERO
	
	
	if not ground_ray.is_colliding():
		return
	
	
	
	# drift input
	if Input.is_action_pressed("jump"):
		is_drifting = true
	else:
		is_drifting = false
		
		
	# drift
	if is_drifting:
		print("drifting!!!")
		speed_input = Input.get_axis("move_back", "move_forward") * drift_acceleration
		turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(drift_steering)
	else:
		speed_input = Input.get_axis("move_back", "move_forward") * acceleration
		turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(steering)
	#right_wheel.rotation.y = turn_input
	#left_wheel.rotation.y = turn_input
	
	# old steering & car mesh positioning method
	if linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		var t = -turn_input * linear_velocity.length() / body_tilt
		#body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)
	
	# new steering
	#if linear_velocity.length() > 0:
		#var current_angle = rotation
		#var angle_diff = wrapf(turn_input - current_angle, -PI, PI)
		#rotation += sign(angle_diff) * min(turn_speed * delta, abs(angle_diff))
		#pass
		
# Function to clamp a Vector3
func clamp_vector3(vector: Vector3, min_vector: Vector3, max_vector: Vector3) -> Vector3:
	return Vector3(
		clamp(vector.x, min_vector.x, max_vector.x),
		clamp(vector.y, min_vector.y, max_vector.y),
		clamp(vector.z, min_vector.z, max_vector.z)
		)
func clamp_velocity(velocity: Vector3, max_length: float) -> Vector3:
	if velocity.length() > max_length:
		return velocity.normalized() * max_length
	return velocity

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
#	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
