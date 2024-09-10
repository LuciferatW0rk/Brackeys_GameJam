extends Node

@onready var player = $CharacterBody3D  # Adjust the path if necessary
@onready var grass_floor = $GrassFloor  # Adjust the path if necessary
@onready var multimesh_instance = grass_floor.get_node("MultiMeshInstance3D")  # Adjust the path if necessary
