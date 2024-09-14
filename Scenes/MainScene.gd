extends Node3D

@onready var hit_rect = $UI/HitRect
@onready var spawns = $Spawns
@onready var navigation_region = $NavigationRegion3D
@onready var music_peace = $Music_Peace
@onready var music_appocalypse = $Music_appocalypse

var days = 0

var zombie = load("res://Scenes/weak_zombie.tscn")
var instance


func _ready():
	pass
	
func _process(delta):
	if days > 0:
		if music_peace.playing:
			music_peace.stop()
			print("Music peace stopped")
		
		if not music_appocalypse.playing:
			music_appocalypse.play()
			print("Music apocalypse started")


func _on_character_body_3d_player_hit():
	print("hit")
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _appocalypse(day):
	if day>1:
		days +=1
		var spawn_point = _get_random_child(spawns).global_position
		instance = zombie.instantiate()
		instance.position = spawn_point
		navigation_region.add_child(instance)
