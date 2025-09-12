@tool
class_name MainMenu
extends Node3D

@export var player_body: XRToolsPlayerBody
@export var level_manager: LevelManager


func _ready() -> void:
	assert(player_body, "Player Body Node not assigned.")
	assert(level_manager, "Level manager node not assigned.")


func _on_start_button_button_pressed() -> void:
	level_manager.set_level(LevelManager.Levels.TUTORIAL_LEVEL)


func _on_set_height_button_button_pressed() -> void:
	if player_body:
		player_body.player_calibrate_height = true


func _on_quit_button_button_pressed() -> void:
	get_tree().quit()
