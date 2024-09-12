extends CharacterBody3D

# Variables for AI movement
@export var roam_radius: float = 10.0 # Radius within which the NPC will roam
@export var move_speed: float = 3.0 # Movement speed of the NPC
@export var wait_time: float = 2.0 # Time to wait before choosing a new direction


@onready var ray_cast_front = $RayCast3D
# Internal variables
var target_position: Vector3
var is_waiting: bool = false

# Timer for roaming
var timer: Timer

# Called when the node is added to the scene
func _ready():
	# Create a timer for wait time between movement
	timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)
	
	# Set initial target position
	target_position = _get_new_random_position()

func _process(delta: float):
	if is_waiting:
		return # Do nothing while waiting

	# Move towards the target position
	var direction: Vector3 = (target_position - global_transform.origin).normalized()
	
	if ray_cast_front.is_colliding():
		direction = -direction
		
	
	velocity = direction * move_speed
	move_and_slide()

	# Check if we've reached the target position
	if global_transform.origin.distance_to(target_position) < 0.5:
		_start_waiting()

# Function to start waiting before moving again
func _start_waiting():
	is_waiting = true
	velocity = Vector3.ZERO
	timer.start()

# Timer callback to choose a new random position
func _on_timer_timeout():
	target_position = _get_new_random_position()
	is_waiting = false

# Get a new random position within the roam radius
func _get_new_random_position() -> Vector3:
	var random_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
	return global_transform.origin + random_direction * randf_range(0.0, roam_radius)
