extends VehicleBody3D

@export var reset_position : Node3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var reverse_camera: Camera3D = $CameraPivot/ReverseCamera


@export var MAX_STEER = .8
@export var ENGINE_POWER = 300 # sesuai sm jumlah ban di mobilnya nnti
@export var NOS_ENGINE_POWER = 3000


var look_at
var desired_engine_power = 0


var debug_initial_rotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Input.is_key_pressed(KEY_R):
		self.position = reset_position.position
		self.linear_velocity = Vector3.ZERO
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	look_at = global_position
	
	debug_initial_rotation = global_rotation
	pass # Replace with function body.

func _process(delta: float) -> void:
	# DEBUG: RESET POSITION 
	if Input.is_key_pressed(KEY_R):
		self.position = reset_position.position
		self.global_rotation = debug_initial_rotation
		self.linear_velocity = Vector3.ZERO
	# NOS
	
	if Input.is_key_pressed(KEY_SPACE):
		desired_engine_power = NOS_ENGINE_POWER
	else:
		desired_engine_power = ENGINE_POWER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("move_back", "move_forward") * desired_engine_power
	
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20.0)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5.0)
	camera_3d.look_at(look_at)
	#_check_camera_switch()
	pass

func _check_camera_switch():
	if linear_velocity.dot(transform.basis.z) > 0:
		camera_3d.current = true
		reverse_camera.current = false
	else:
		reverse_camera.current = true
		camera_3d.current = false
	pass
