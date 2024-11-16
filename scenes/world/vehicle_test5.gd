extends VehicleBody3D
# damn pls work


var throttle_input = 0
var steering_input = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	throttle_input = Input.get_axis("move_back", "move_forward")
	steering_input = Input.get_axis("move_left", "move_right")
	
	
	
	
	
	self.engine_force = lerp(engine_force, 120 * throttle_input, delta)
	self.steering = steering_input
	
	pass
	
func _physics_process(delta: float) -> void:
	pass
