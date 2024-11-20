extends Node3D
@onready var parent_node = $".."
@onready var car_rigidbody = $"../SphereRB"
@onready var car_mesh = self
#@onready var body_mesh = $CarMesh/body
@onready var ground_ray = $"../RayCast3D"
#@onready var right_wheel = $"CarMesh/wheel-front-right"
#@onready var left_wheel = $"CarMesh/wheel-front-left"

@export var carResetPosition : Node3D
# Where to place the car mesh relative to the sphere
@export_category("General Vehicle Settings")
#@export var sphere_offset = Vector3.DOWN
@export var car_position_offset = Vector3.DOWN
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if ground_ray.is_colliding():
		if turn_input > 0 and turn_input < 0:		# turn input NOT PRESSED
			car_rigidbody.apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
		else:		# turn input pressed
			if speed_input != 0:
				car_rigidbody.apply_central_force(-car_mesh.global_transform.basis.z * 2.5 * speed_input)
			else:	
				car_rigidbody.rotate(Vector3.UP, turn_input)
				
		# clamp velocity
		car_rigidbody.linear_velocity = clamp_velocity(car_rigidbody.linear_velocity, top_speed)
		#print("(DEBUG) speed: " + str(linear_velocity))
		pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# DEBUG respawn
	if Input.is_key_pressed(KEY_R):
		parent_node.position = carResetPosition.position
		car_rigidbody.linear_velocity = Vector3.ZERO
	
	# sync mesh to rb
	self.global_position = car_rigidbody.global_position + car_position_offset
	
	if not ground_ray.is_colliding():
		return
	
	# drift input
	if Input.is_action_pressed("jump"):
		is_drifting = true
	else:
		is_drifting = false
		
		
	# drift
	if is_drifting:
		# print("drifting!!!")
		speed_input = Input.get_axis("move_back", "move_forward") * drift_acceleration
		turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(drift_steering)
	else:
		speed_input = Input.get_axis("move_back", "move_forward") * acceleration
		turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(steering)
	#right_wheel.rotation.y = turn_input
	#left_wheel.rotation.y = turn_input
	
	# old steering & car mesh positioning method
	if car_rigidbody.linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		var t = -turn_input * car_rigidbody.linear_velocity.length() / body_tilt
		#body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

	pass
	
func clamp_velocity(velocity: Vector3, max_length: float) -> Vector3:
	if velocity.length() > max_length:
		return velocity.normalized() * max_length
	return velocity

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
#	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
