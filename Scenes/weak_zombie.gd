extends CharacterBody3D

var player = null
var is_attacking = false  # Track if the zombie is currently attacking
var attack_animation_duration = 0.0  # Duration of the attack animation

const SPEED = 4.0
const ATTACK_RANGE = 1.5

@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $weak_zombie/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	# Get the duration of the attack animation
	attack_animation_duration = anim_player.get_animation("zombie_attacking").length
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	if _target_in_range():
		# Attack player if in range
		if not is_attacking:
			# Start the attack animation
			anim_player.play("zombie_attacking")
			is_attacking = true
		# Keep looking at the player while attacking
		look_at(Vector3(player.global_transform.origin.x, global_transform.origin.y, player.global_transform.origin.z), Vector3.UP)
	else:
		# If player is not in range, switch to running animation only if attack animation is done
		if is_attacking:
			# Start a coroutine to wait for the attack animation to finish
			_start_animation_wait()
		else:
			# Move towards the player
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
			# Rotate towards the player while running
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
	
	move_and_slide()
	
# Function to check if the player is within attack range
func _target_in_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) < ATTACK_RANGE

# Coroutine to wait for the attack animation to finish
func _start_animation_wait() -> void:
	# Wait until the attack animation is done
	await get_tree().create_timer(attack_animation_duration).timeout
	# Stop attacking and switch to running animation
	anim_player.play("running_zombie")
	is_attacking = false
