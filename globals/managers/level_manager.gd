class_name LevelManager
extends Node3D

enum Levels { TUTORIAL_LEVEL }

@export var xr_camera_3d: XRCamera3D
@export var player: Player
@export_group("Levels")
@export var tutorial_level_scene: PackedScene
@export_group("Transition Menus")
@export var level_complete: PackedScene
@export var level_failed: PackedScene

var _current_level: Levels

@onready var game_objects: Node3D = %GameObjects
@onready var script_manager: ScriptManager = $"../ScriptManager"


func _ready() -> void:
	assert(tutorial_level_scene, "Tutorial level scene not set in LevelManager.")


func set_level(level: Levels) -> void:
	var new_level: Node3D

	for child in game_objects.get_children():
		child.queue_free()

	match level:
		Levels.TUTORIAL_LEVEL:
			new_level = tutorial_level_scene.instantiate()

	# Remember current progress
	_current_level = level
	
	# Set up level in tree
	game_objects.add_child(new_level)
	new_level.set_script_manager(script_manager)
	new_level.set_player_reference(player)
	
	# Connect level signals
	new_level.level_complete.connect(_on_level_complete)
	new_level.level_failed.connect(_on_level_failed)
	
	# Position the objects in front of the player.
	new_level.global_position = (
		xr_camera_3d.global_position + Vector3(0.0, -0.35 * xr_camera_3d.global_position.y, -1.0)
	)
	new_level.start_level()


func _on_level_complete(timing: float) -> void:
	pass


func _on_level_failed() -> void:
	pass
