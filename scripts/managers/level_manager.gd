class_name LevelManager
extends Node3D

@onready var game_objects: Node3D = %GameObjects
@onready var script_manager: ScriptManager = $"../ScriptManager"

@export var xr_camera_3d: XRCamera3D
@export_group("Levels")
@export var tutorial_level_scene: PackedScene

enum Levels { TUTORIAL_LEVEL }


func _ready() -> void:
	assert(tutorial_level_scene, "Tutorial level scene not set in LevelManager.")


func set_level(level: Levels) -> void:
	var new_level: Node3D

	for child in game_objects.get_children():
		child.queue_free()

	match level:
		Levels.TUTORIAL_LEVEL:
			new_level = tutorial_level_scene.instantiate()

	game_objects.add_child(new_level)
	new_level.set_script_manager(script_manager)
	# Position the objects in front of the player.
	new_level.global_position = (
		xr_camera_3d.global_position + Vector3(0.0, -0.25 * xr_camera_3d.global_position.y, -1.0)
	)
	new_level.start_level()
