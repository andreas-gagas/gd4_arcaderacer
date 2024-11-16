extends Node3D
@export var script_enabled : bool = true
@export var source_transform : Node3D

@export_category("Settings")
@export var copy_x : bool = false
@export var copy_y : bool = false
@export var copy_z : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if source_transform == null:
		script_enabled = false
		print("WARNING: (copy_selected_rotation.gd) source transform is not set in the inspector!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if script_enabled:
		if (copy_x):
			self.global_rotation = Vector3(source_transform.global_rotation.x, self.global_rotation.y, self.global_rotation.z)
		if (copy_y):
			self.global_rotation = Vector3(self.global_rotation.x, source_transform.global_rotation.y, self.global_rotation.z)
		if (copy_z):
			self.global_rotation = Vector3(self.global_rotation.x, self.global_rotation.y, source_transform.global_rotation.z)
		pass
	pass
