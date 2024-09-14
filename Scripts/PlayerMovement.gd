extends CharacterBody3D

var speed
var player_health = 100
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004
const HIT_STAGGER = 6.0

# Bob variables
const BOB_FREQ = 1.0
const BOB_AMP = 0.1
var t_bob = 0.0

#signal
signal player_hit

var gravity = 9.8

var bullet_glock = load("res://bullet_glock.tscn")
var instance 
var can_shoot = true 

@onready var healthbar = $Head/Camera3D/Sprite3D/SubViewport/ProgressBar
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var glock_anim = $Head/Camera3D/Glock/AnimationPlayer
@onready var glock_barrel = $Head/Camera3D/Glock/RayCast3D
@onready var label_death = $Head/Camera3D/Sprite3D/SubViewport/Label
@onready var label_2 = $Head/Camera3D/Sprite3D/SubViewport/Label2
@onready var shot = $shot


func _ready():
	label_death.visible = false
	healthbar.max_value = player_health
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		
	# Handle Sprint
	if Input.is_action_pressed("shift"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED


	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 


	# Get input direction and handle movement
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob) * 0.5
	
	#shooting
	if Input.is_action_just_pressed("shoot") and can_shoot:
		# Start shooting if the player is allowed to shoot
		fire_gun()
	move_and_slide()

func fire_gun():
	if !glock_anim.is_playing():
		shot.play()  # Play the shooting sound
		glock_anim.play("shoot")  # Play the shooting animation
		
		# Create the bullet instance and set its position and rotation
		var instance = bullet_glock.instantiate()
		instance.position = glock_barrel.global_position
		instance.transform.basis = glock_barrel.global_transform.basis
		get_parent().add_child(instance)
		
		# Disable shooting until the cooldown period is over
		can_shoot = false
		
		# Start the cooldown timer for shooting
		await get_tree().create_timer(0.5).timeout  # 1-second delay (change if needed)
		
		# Re-enable shooting after the cooldown period
		can_shoot = true


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP 
	return pos

func hit(dir):
	if player_health > 0:
		velocity += dir * HIT_STAGGER
		healthbar.value -= 10
		player_health -= 10
		print("player hit")
		print("health = " , player_health)
		emit_signal("player_hit")
	else:
		label_death.visible = true
		#get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#queue_free()

func _increment_day(day):
	label_2.text = "Day "+ str(day)
