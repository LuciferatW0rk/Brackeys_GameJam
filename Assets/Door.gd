extends StaticBody3D

var toggle = false
var interactable = true
@export var animation_player: AnimationPlayer

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("Close")
		if toggle == true:
			animation_player.play("Open")
		await get_tree().create_timer(1.0, false).timeout
		interactable = true
