class_name LevelManager
extends Node3D

@onready var game_objects: Node3D = %GameObjects
@onready var player_body: XRToolsPlayerBody = $"../Player/PlayerBody"

@export_group("Levels")
@export var TutorialLevel: PackedScene


enum Levels {
	TUTORIAL_LEVEL
}


func set_level(level: Levels) -> void:
	var new_level: Node3D 
	
	for child in game_objects.get_children():
		child.queue_free()
	
	match level:
		Levels.TUTORIAL_LEVEL:
			new_level = TutorialLevel.instantiate()
	
	game_objects.add_child(new_level)
	# Position the objects in front of the player.
	new_level.global_position = player_body.global_position + Vector3(0.0, player_body.player_head_height/2.0, -0.2)
	
