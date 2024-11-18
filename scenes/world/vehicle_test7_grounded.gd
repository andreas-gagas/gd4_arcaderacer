extends Node
@onready var vehicle_root: RigidBody3D = $"../.."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_state_machine_player_updated(source: Variant, state: Variant, delta: Variant) -> void:
	#print(source + " : " + state + " : " + str(delta))
	if source == "process":
		fsm_process(delta)
	elif source == "physics":
		fsm_physics(delta)
	pass # Replace with function body.

func fsm_process(delta : float):
	pass

func fsm_physics(delta : float):
	pass
