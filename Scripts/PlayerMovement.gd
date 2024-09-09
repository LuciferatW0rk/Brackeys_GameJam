extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

# Bob variables
const BOB_FREQ = 1.0
const BOB_AMP = 0.2
var t_bob = 0.0

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var animation_controller = $"Animation Controller"  # Reference the Animation Controller node


func _ready():
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
		
	# Debug input states
	print("Forward Pressed: ", Input.is_action_pressed("forward"))
	print("Sprint Pressed: ", Input.is_action_pressed("sprint"))

	# Handle Sprint
	if Input.is_action_pressed("shift"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Debug speed
	print("Current Speed: ", speed)

	# Movement and animation logic...
	if Input.is_action_pressed("forward") and is_on_floor():
		if Input.is_action_pressed("shift") and is_on_floor():
			animation_controller.play_animation("run")
		else:
			animation_controller.play_animation("walk")
		
	else:
		animation_controller.play_animation("idle")

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
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP / 2
	return pos
