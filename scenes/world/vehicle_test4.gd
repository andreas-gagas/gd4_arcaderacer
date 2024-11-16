extends Node3D

# Declarations
@onready var kart_normal = $"Rotation Offset"
@onready var sphere = $"../SphereRB"
@onready var ray_on = $"../RayOn"
@onready var ray_near = $"../RayNear"

var speed = 0.0
var current_speed = 0.0
var rotate = 0.0
var current_rotate = 0.0
var drift_direction = 0
var drift_power = 0.0
var drift_mode = 0
var first = false
var second = false
var third = false

# Bools
var drifting = false

# Parameters
@export var acceleration = 30.0
@export var steering = 80.0
@export var gravity = 10.0
@export var layer_mask = 0

func _ready():
	pass

func _process(delta):
# Follow Collider
	global_transform.origin = sphere.global_transform.origin - Vector3(0, 0.4, 0)

	# Accelerate
	if Input.is_action_pressed("move_forward"):
		speed = acceleration

	# Steer
	var move_left_right = Input.get_axis("move_left", "move_right")
	if Input.get_axis("move_left", "move_right") != 0:
		var dir = 1 if move_left_right > 0 else -1
		var amount = abs(Input.get_axis("move_left", "move_right"))
		steer(dir, amount)

	# Drift
	if Input.is_action_just_pressed("jump") and not drifting and Input.get_axis("move_left", "move_right") != 0:
		drifting = true
		drift_direction = 1 if move_left_right > 0 else -1

	if drifting:
		var control = remap(move_left_right, -1, 1, 0, 2) if drift_direction == 1 else remap(move_left_right, -1, 1, 2, 0)
		var power_control = remap(move_left_right, -1, 1, 0.2, 1) if drift_direction == 1 else remap(move_left_right, -1, 1, 1, 0.2)
		steer(drift_direction, control)
		drift_power += power_control
		
	if Input.is_action_just_released("jump") and drifting:
		boost()

	current_speed = lerp(current_speed, speed, delta * 12.0)
	speed = 0.0
	current_rotate = lerp(current_rotate, rotate, delta * 4.0)
	rotate = 0.0

func _physics_process(delta):
	# Forward Acceleration
	if not drifting:
		sphere.apply_central_force(-transform.basis.x * current_speed)
	else:
		sphere.apply_central_force(global_transform.basis.z * current_speed)

	# Gravity
	sphere.apply_central_force(Vector3(0, -gravity, 0))

	# Steering
	global_transform.basis = lerp(global_transform.basis, Basis(Vector3(0, 1, 0), deg_to_rad(current_rotate)), delta * 5.0)

	# Normal Rotation using RayCasts
	if ray_near.is_colliding():
		var hit_normal = ray_near.get_collision_normal()
		var kart_normal_transform = kart_normal.transform
		kart_normal_transform.basis.y = lerp(kart_normal_transform.basis.y, hit_normal, delta * 8.0)
		kart_normal_transform.basis = kart_normal_transform.basis.orthonormalized()
		kart_normal.transform = kart_normal_transform
		kart_normal.rotate(Vector3.UP, deg_to_rad(global_transform.basis.get_euler().y))
	

func boost():
	drifting = false

	if drift_mode > 0:
		current_speed = lerp(current_speed * 3, current_speed, 0.3 * drift_mode)

	drift_power = 0.0
	drift_mode = 0
	first = false
	second = false
	third = false

func steer(direction, amount):
	rotate = (steering * direction) * amount

# Extension methods
func remap(value, from_min, from_max, to_min, to_max):
	return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
