extends RigidBody3D
@onready var ground_ray : RayCast3D = $RayCast3D
@onready var collisionSphere = $CollisionSphere

# Where to place the car mesh relative to the sphere
@export var sphere_offset = Vector3.DOWN
# Engine power
@export var acceleration = 35.0
# Turn amount, in degrees
@export var steering = 18.0
# How quickly the car turns
@export var turn_speed = 4.0
# Below this speed, the car doesn't turn
@export var turn_stop_limit = 0.75
@export var body_tilt = 35
@export var isGrounded : bool

# Variables for input values
var speed_input = 0
var turn_input = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ground_ray.add_exception_rid(collisionSphere)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# debug key
	if Input.is_key_pressed(KEY_SPACE):
		self.global_position = self.global_position + (Vector3.UP)
		pass
	
	# update isGrounded
	isGrounded = ground_ray.is_colliding()
	
	if not ground_ray.is_colliding():
		return
	# input
	speed_input = Input.get_axis("move_back", "move_forward") * acceleration
	turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(steering)
	
	self.rotate(Vector3.UP, turn_input * delta)
	
	# turning
	#if linear_velocity.length() > turn_stop_limit:
		##var new_basis = self.global_transform.basis.rotated(self.global_transform.basis.y, turn_input)
		##self.global_transform.basis = self.global_transform.basis.slerp(new_basis, turn_speed * delta)
		##self.global_transform = self.global_transform.orthonormalized()
		#self.rotate(Vector3.UP, turn_input / 50)
	pass
	
func _physics_process(delta: float) -> void:
	if ground_ray.is_colliding():
		#print("Grounded!!")
		apply_central_force(-ground_ray.global_transform.basis.z * speed_input)
		pass
	else:
		print("NOT grounded!")
	pass
