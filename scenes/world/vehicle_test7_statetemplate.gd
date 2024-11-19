extends Node
# DONT FORGET TO ADD THIS STATE'S NODE TO vehicle_root NODE!!!!
# ALSO DONT FORGET TO CONNECT THE SIGNALS!!

@onready var vehicle_root: RigidBody3D = $"../.."
@onready var fsm: Node = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func fsm_process(delta : float) -> void:
	pass
	
func fsm_physics(delta : float) -> void:
	pass

func _on_state_machine_player_updated(source: Variant, state: Variant, delta: Variant) -> void:
	#print(source + " : " + state + " : " + str(delta))
	if state == vehicle_root.state_template.name:
		if source == "process":
			fsm_process(delta)
		elif source == "physics":
			fsm_physics(delta)
	pass # Replace with function body.


func _on_state_machine_player_entered(to: Variant) -> void:
	print("hello im at (statename)")
	pass # Replace with function body.
