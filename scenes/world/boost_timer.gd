extends Node
signal timer_finished()

@export var timerFinished : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_timer(delta)
	pass

var timer : float = 0
func process_timer(delta : float) -> void:
	if timer > 0:
		timer -= delta
		pass
	elif timer <= 0:
		timer_finished.emit()
		timerFinished = true
	pass

func set_timer_duration(time : float) -> void:
	timer = time
	timerFinished = false
	pass
	
func get_timer_duration() -> float:
	return timer
