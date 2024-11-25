extends RigidBody3D
# damn pls end this suffering (in a good way)
# okay it finally done! (the base); it was studied from wallaber's racing game 
@export_category("General Settings")
@export var springs : Array[Node3D]		## the springs that will be used to keep vehicle from touching ground. add the spring prefab to this car_mesh child and reference it into this array
@export var top_speed_fwd : float = 20		## top speed when going forward
@export var top_speed_back : float = 20		## top speed when reversing
@export var force_responsiveness : float = 0.2		## yes...
@export var turn_accel : float = 360	## also, yes...
@export var acceleration_fwd : float = 40	## forward acceleration
@export var acceleration_back : float = 40	## backward acceleration
@export var braking_decel : float = 100		## how much force to apply when vehicle is braking
@export var max_turn_speed = 60				## how fast vehicle turns???
@export_range(5.5, 20) var drift_strength = 10		## how "grippy" is the drift? 7.5 is not grippy, 15 is really grippy (also affected by top speed btw)
@export var remaining_boost_duration = 0	## self explanatory, maybe i gotta split this per drift boost tier

@export_category("Boost")
@export var drifting_boost_acceleration_fwd : float = 40	## drifting boost forward acceleration
@export var drifting_first_boost_top_speed_addition_fwd : float = 10	## the amount to add to current top speed when player get the first tier drift boost
@export var drifting_second_boost_top_speed_addition_fwd : float = 20	## the amount to add to current top speed when player get the second tier drift boost
@export var first_boost_speed_addition : float = 10
@export var second_boost_speed_addition : float = 20
@export var first_boost_duration : float = 3
@export var second_boost_duration : float = 2
@export var minimum_drift_duration_for_first_boost : float = 2.0 
@export var minimum_drift_duration_for_second_boost : float = 4.0 

@onready var fsm: Node = $StateMachinePlayer
@onready var state_grounded: Node = $StateMachinePlayer/Grounded
@onready var state_airborne: Node = $StateMachinePlayer/Airborne
@onready var state_drifting: Node = $StateMachinePlayer/Drifting

# Drifting state stuff
@onready var car_mesh_rotation_offset: Node3D = $CarMeshRotationOffset
@onready var drift_particles: GPUParticles3D = $"CarMeshRotationOffset/car_mesh/Wheel Particles/drift_particles"
@onready var boost1_drift_particles: GPUParticles3D = $"CarMeshRotationOffset/car_mesh/Wheel Particles/boost1_drift_particles"
@onready var boost2_drift_particles: GPUParticles3D = $"CarMeshRotationOffset/car_mesh/Wheel Particles/boost2_drift_particles"



var drift_dir : drift_direction = drift_direction.NONE

enum drift_direction { NONE, LEFT, RIGHT }
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
