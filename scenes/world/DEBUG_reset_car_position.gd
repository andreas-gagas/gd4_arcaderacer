extends Node3D
@export var car_node : RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_key_1"):
		car_node.global_position = self.global_position
		car_node.linear_velocity = Vector3.ZERO
	pass

func _input(event: InputEvent) -> void:
	pass
