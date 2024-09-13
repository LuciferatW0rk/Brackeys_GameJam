extends Node3D

@onready var hit_rect = $UI/HitRect

func _ready():
	pass
	
func _process(delta):
	pass
	

func _on_character_body_3d_player_hit():
	print("hit")
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	
