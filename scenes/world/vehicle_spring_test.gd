extends Node3D

@onready var raycast : RayCast3D = $RayCast3D
@onready var pivot: Node3D = $Pivot
@onready var vertical_pivot: Node3D = $Pivot/vertical_pivot


@export var spring_strength : float = 10
@export var spring_damping : float = 10
@export var tire_radius : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _physics_process(delta: float) -> void:
	stick_tires_to_ground()
	pass

func update_spring(rigidbody : RigidBody3D, delta : float) -> void:
	if raycast.is_colliding():
		var hit_pos = raycast.get_collision_point()
		var max_length = abs(raycast.target_position.y)
		var cur_length = global_position.distance_to(hit_pos)
		var spring_dampingIThink = max_length - cur_length
		
		#dibawah ini blm tau buat apa
		var vel_at_spring = rigidbody._get_point_velocity(global_position)
		var spring_vel = vel_at_spring.dot(Vector3.UP)
		var calculated_spring_force = spring_dampingIThink * spring_strength
		var calculated_spring_damping = spring_vel * spring_damping
		var final_spring_force = calculated_spring_force - calculated_spring_damping
		
		rigidbody.apply_force(Vector3.UP * final_spring_force, global_position - rigidbody.global_position)
		#print(self.name + " : " + str(global_position - rigidbody.global_position))
		pass
	pass

# this is purely only for visual stuff
func _spin_tires(vel:float, accel:float, max_vel:float, delta:float) -> void:
	var v = vel;
	if (accel >= 1.0):
		v = max_vel
	if (accel <= -1.0):
		v = 0
		
	var angle_change = (v * delta) / tire_radius
	
	pivot.rotate_object_local(Vector3.RIGHT, angle_change)
	
func stick_tires_to_ground():
	if raycast.is_colliding():	# if hits ground, put tires on ground
		vertical_pivot.global_position.y = raycast.get_collision_point().y
		pass
	else:	# put tires on raycast target
		# temporarily reset position
		vertical_pivot.position = Vector3(0, 0, 0)
		# move tires to raycast target
		vertical_pivot.position.y = raycast.target_position.y
		pass
	pass
