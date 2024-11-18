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

@onready var fsm: Node = $StateMachinePlayer
@onready var state_grounded: Node = $StateMachinePlayer/Grounded
@onready var state_airborne: Node = $StateMachinePlayer/Airborne

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fsm.update("process", delta)
	
	pass
	
func _physics_process(delta: float) -> void:
	fsm.update("physics", delta)
	
func _get_point_velocity(point : Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - to_global(center_of_mass))
	pass
