extends Node

@onready var anim_player = $"../Head/Camera3D/PlayerCharacterWithoutWeapon/AnimationPlayer"

func _ready():
	# Ensure the AnimationPlayer node is correctly referenced
	if anim_player:
		anim_player.connect("animation_finished", Callable(self, "_on_animation_player_animation_finished"))
	else:
		print("Error: AnimationPlayer node not found.")

func _check_and_switch_to_idle():
	# Transition to idle if no actions are being performed
	if not Input.is_action_pressed("sprint") and not Input.get_vector("left", "right", "forward", "back").length() > 0:
		play_animation("idle")  # Ensure "idle" is the name of your idle animation

func play_animation(anim_name: String):
	if anim_player:
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name)


