extends CharacterBody3D

var player = null
var is_attacking = false  # Track if the zombie is currently attacking
var attack_animation_duration = 0.0  # Duration of the attack animation
var stand_up_done = false  # Track if the stand-up animation is finished
var health = 10


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
	
	# Play the stand-up animation when the zombie spawns
	anim_player.play("standup")
	_start_stand_up_wait()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not stand_up_done:
		health = 10
		# Wait for the stand-up animation to complete before allowing movement
		return
	
	velocity = Vector3.ZERO
	if health > 0:
		if _target_in_range() :
			# Attack player if in range
			if not is_attacking :
				# Start the attack animation
				anim_player.play("zombie_attacking")
				is_attacking = true
				player.hit()
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
		
	if health >0:
		move_and_slide()

# Function to check if the player is within attack range
func _target_in_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) < ATTACK_RANGE

# Coroutine to wait for the attack animation to finish
func _start_animation_wait() -> void:
	# Wait until the attack animation is done
	await get_tree().create_timer(attack_animation_duration/2).timeout
	# Stop attacking and switch to running animation
	if health >0 :
		anim_player.play("running_zombie")
	is_attacking = false

# Coroutine to wait for the stand-up animation to finish before following the player
func _start_stand_up_wait() -> void:
	var stand_up_duration = anim_player.get_animation("standup").length
	# Wait until the stand-up animation is done
	await get_tree().create_timer(stand_up_duration).timeout
	stand_up_done = true
	# Switch to running zombie animation after standing up
	if health >0 :
		anim_player.play("running_zombie")

func _hit_finished():
	print("hit finished")
	player.hit()

func hit():
	if health >0:
		health -= 1
		print(health)
		if health <= 0:
			anim_player.play("zombie_dying")  # Play the death animation 
			_start_death_wait()  # Wait for the animation to finish before queue_free()



# Coroutine to wait for the death animation to finish
func _start_death_wait() -> void:
	var death_animation_duration = anim_player.get_animation("zombie_dying").length
	# Wait until the death animation is done
	await get_tree().create_timer(death_animation_duration).timeout
	queue_free()  # Remove the zombie after the animation

