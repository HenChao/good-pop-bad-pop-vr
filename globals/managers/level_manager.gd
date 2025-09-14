class_name LevelManager
extends Node3D
## Manages the game levels, and handle setup/transition/teardown of scenes.

enum Levels { MAIN_MENU, TUTORIAL_LEVEL, LEVEL_1, LEVEL_2, LEVEL_3, END_GAME }

# References to nodes in tree for programmatic access.
@export var xr_camera_3d: XRCamera3D
@export var player: Player
@export var game_objects: Node3D
@export var script_manager: ScriptManager

@export_group("Levels")
@export var main_menu_scene: PackedScene
@export var tutorial_level_scene: PackedScene
@export var level_1_scene: PackedScene
@export var level_2_scene: PackedScene
@export var level_3_scene: PackedScene
@export var end_game_scene: PackedScene

@export_group("Transition Menus")
@export var level_complete: PackedScene
@export var level_failed: PackedScene

## Internal reference to the current level the Player is on.
var _current_level: Levels


func _ready() -> void:
	assert(xr_camera_3d, "XRCamera3D node not set in LevelManager.")
	assert(player, "Player node not set in LevelManager.")
	assert(game_objects, "Game Objects node not set in LevelManager.")
	assert(script_manager, "Script Manager node not set in LevelManager.")

	assert(tutorial_level_scene, "Tutorial level scene not set in LevelManager.")
	assert(level_1_scene, "Level 1 scene not set in LevelManager.")
	assert(level_2_scene, "Level 2 scene not set in LevelManager.")
	assert(level_3_scene, "Level 3 scene not set in LevelManager.")
	assert(end_game_scene, "End Game scene not set in LevelManager.")


## Set the level to be played in-game.
func set_level(level: Levels) -> void:
	var new_level: Node3D

	# Clean up all previously loaded objects to start a clean scene.
	for child in game_objects.get_children():
		child.queue_free()

	match level:
		Levels.MAIN_MENU:
			_setup_main_menu()
			return
		Levels.TUTORIAL_LEVEL:
			new_level = tutorial_level_scene.instantiate()
		Levels.LEVEL_1:
			new_level = level_1_scene.instantiate()
		Levels.LEVEL_2:
			new_level = level_2_scene.instantiate()
		Levels.LEVEL_3:
			new_level = level_3_scene.instantiate()
		Levels.END_GAME:
			new_level = end_game_scene.instantiate()

	# Remember current progress
	_current_level = level

	# Set up level in tree and pass required references to the new level.
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

	# Now ready to start the level.
	new_level.start_level()


## Called when the player completes the level. Transition and show the appropriate menu scene.
func _on_level_complete(timing: float) -> void:
	for child in game_objects.get_children():
		child.queue_free()

	## If at the end of the game, don't show the victory screen. Just go to the Main Menu level.
	if _current_level == Levels.END_GAME:
		return set_level(Levels.MAIN_MENU)

	var victory_menu: Victory = level_complete.instantiate()
	game_objects.add_child(victory_menu)
	victory_menu.position = Vector3(0, 1.5, -10)
	victory_menu.set_level_time(timing)
	victory_menu.next_level_pressed.connect(
		func():
			match _current_level:
				Levels.TUTORIAL_LEVEL:
					set_level(Levels.LEVEL_1)
				Levels.LEVEL_1:
					set_level(Levels.LEVEL_2)
				Levels.LEVEL_2:
					set_level(Levels.LEVEL_3)
				Levels.LEVEL_3:
					set_level(Levels.END_GAME)
	)


## Called when the player fails the level. Either due to timeout or low mood.
## Transition and show the game over menu scene.
func _on_level_failed() -> void:
	for child in game_objects.get_children():
		child.queue_free()

	var game_over_menu: GameOver = level_failed.instantiate()
	game_objects.add_child(game_over_menu)
	game_over_menu.position = Vector3(0, 1.5, -10)
	# Replay the same level if restart option was selected.
	game_over_menu.restart_pressed.connect(set_level.bind(_current_level))


## Set up the main menu objects after restarting from the end of the game.
func _setup_main_menu() -> void:
	var menu_objects: MainMenu = main_menu_scene.instantiate()
	menu_objects.player_body = player.get_node("PlayerBody")
	menu_objects.level_manager = self
	game_objects.add_child(menu_objects)
	menu_objects.position = Vector3(0, 1.5, -10)
	_current_level = Levels.MAIN_MENU
