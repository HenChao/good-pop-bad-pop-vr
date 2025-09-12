@tool
class_name PausedMenu
extends Node3D

signal resume_game_button_pressed

@export var player_body: XRToolsPlayerBody


func _ready() -> void:
	assert(player_body, "Player Body Node not assigned.")


func _on_set_height_button_button_pressed() -> void:
	if player_body:
		player_body.player_calibrate_height = true


func _on_quit_button_button_pressed() -> void:
	get_tree().quit()


func _on_resume_button_button_pressed() -> void:
	resume_game_button_pressed.emit()
