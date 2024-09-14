extends CharacterBody3D

var player = null
var is_attacking = false  # Track if the zombie is currently attacking
var attack_animation_duration = 0.0  # Duration of the attack animation
var stand_up_done = false  # Track if the stand-up animation is finished
var health = 10

const SPEED = 4.0
const ATTACK_RANGE = 1.5

@onready var healthbar = $Sprite3D/SubViewport/ProgressBar

@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $weak_zombie/AnimationPlayer
@onready var attack_sound = $"attack sound"
@onready var zombie_sound = $zombie_sound

func _ready():
	player = get_node(player_path)
	# Get the duration of the attack animation
	attack_animation_duration = anim_player.get_animation("zombie_attacking").length
	
	# Play the stand-up animation when the zombie spawns
	anim_player.play("standup")
	_start_stand_up_wait()

func _process(delta):
	if not stand_up_done:
		health = 10
		return  # Wait for the stand-up animation to complete before allowing movement
	
	velocity = Vector3.ZERO
	if health > 0:
		if _target_in_range():
			# Stop the running sound when attacking
			if zombie_sound.is_playing():
				zombie_sound.stop()
			# Attack player if in range
			if not is_attacking:
				attack_sound.play()
				anim_player.play("zombie_attacking")
				is_attacking = true
			look_at(Vector3(player.global_transform.origin.x, global_transform.origin.y, player.global_transform.origin.z), Vector3.UP)
		else:
			if is_attacking:
				_start_animation_wait()
			else:
				# If the zombie is moving and not attacking, play the zombie sound
				if not zombie_sound.is_playing():
					zombie_sound.play()
				# Move towards the player
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
				
				# Rotate towards the player while running
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)

	if health > 0:
		move_and_slide()

func _target_in_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) < ATTACK_RANGE

func _start_animation_wait() -> void:
	await get_tree().create_timer(attack_animation_duration / 2).timeout
	if health > 0:
		anim_player.play("running_zombie")
		if not zombie_sound.is_playing():
			zombie_sound.play()  # Resume running sound if the zombie starts running again
	is_attacking = false

func _start_stand_up_wait() -> void:
	var stand_up_duration = anim_player.get_animation("standup").length
	await get_tree().create_timer(stand_up_duration).timeout
	stand_up_done = true
	if health > 0:
		anim_player.play("running_zombie")

func _hit_finished():
	if global_transform.origin.distance_to(player.global_transform.origin) < ATTACK_RANGE + 1:
		var dir = (player.global_transform.origin - global_transform.origin).normalized()
		print("hit finished")
		player.hit(dir)

func hit():
	if health > 0:
		healthbar.value -= 1
		health -= 1
		print(health)
		if health <= 0:
			anim_player.play("zombie_dying")
			_start_death_wait()

func _start_death_wait() -> void:
	var death_animation_duration = anim_player.get_animation("zombie_dying").length
	await get_tree().create_timer(death_animation_duration).timeout
	zombie_sound.stop()  #stop sound when zombie dies
	queue_free()
