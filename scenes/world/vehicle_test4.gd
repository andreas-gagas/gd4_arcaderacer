extends Node3D
@onready var parent_node = $".."
@onready var car_rigidbody = $"../SphereRB"
@onready var ground_ray = $"../RayCast3D"

@export var carResetPosition : Node3D

@export var is_drifting = false

@export var acceleration = 30
@export var steering = 80
@export var gravity = 10
@export var car_position_offset = Vector3.DOWN


var speed_input = 0
var turn_input = 0


var current_speed = 0
var current_rotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	#car_rigidbody.apply_force(-self.global_basis.z * , self.transform)
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
	
	
	# inputs
	if Input.is_action_pressed("move_forward"):
		speed_input = acceleration
	turn_input = Input.get_axis("move_right", "move_left")
	#speed_input = Input.get_axis("move_back", "move_forward") * acceleration
	#turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(steering)
	
	
	current_speed = smoothstep(current_speed, speed_input, delta * 12)
	speed_input = 0
	
	current_rotation = lerp(current_rotation, rotate)
	pass

func steer(direction : int, amount : float) -> float:
	return (steering * direction) * amount
