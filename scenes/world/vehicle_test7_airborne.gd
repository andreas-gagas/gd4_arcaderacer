extends Node

@onready var vehicle_root: RigidBody3D = $"../.."

@onready var fsm: Node = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func fsm_process(delta : float):
	if Input.is_key_pressed(KEY_E):
		fsm.set_trigger("Airborne->Grounded")
	pass

func fsm_physics(delta : float):
	pass

func _on_state_machine_player_updated(source: Variant, state: Variant, delta: Variant) -> void:
	#print(source + " : " + state + " : " + str(delta))
	if state == vehicle_root.state_airborne.name:
		if source == "process":
			fsm_process(delta)
		elif source == "physics":
			fsm_physics(delta)
	pass # Replace with function body.


func _on_state_machine_player_entered(to: Variant) -> void:
	print("hello im at " + str(to))

	pass # Replace with function body.
