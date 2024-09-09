extends Node3D

@export var running_head_offset : float = -0.1  # Adjust this value to control how much the head moves forward
@export var idle_head_offset : float = 0.0     # The default position when not running

var is_running : bool = false
var original_position : Vector3

func _ready():
	original_position = position

func _process(delta):
	if is_running:
		# Move the head forward when running
		position.z = original_position.z + running_head_offset
	else:
		# Reset to original position when not running
		position.z = original_position.z + idle_head_offset

func set_running_state(running : bool):
	is_running = running
