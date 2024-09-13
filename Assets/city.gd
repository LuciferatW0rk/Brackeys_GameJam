extends Node3D


@onready var path_follow_lady1 = $Path3D/PathFollow3D
@onready var path_follow_lady2 = $Path3D/PathFollow3D2
@onready var path_follow_surgeon = $Path3D/PathFollow3D3
@onready var path_follow_chad = $Path3D/PathFollow3D4
# Called when the node enters the scene tree for the first time.
func _ready() -> void :
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	path_follow_lady1.progress += 3 * delta
	path_follow_lady2.progress += 2.5 * delta 
	path_follow_surgeon.progress += 3.2 * delta
	path_follow_chad.progress += 3.5 * delta
