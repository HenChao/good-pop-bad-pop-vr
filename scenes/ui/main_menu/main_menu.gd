@tool
class_name MainMenu
extends Node3D

@export var player_body: XRToolsPlayerBody


func _on_start_button_button_pressed() -> void:
	pass # Replace with function body.


func _on_set_height_button_button_pressed() -> void:
	if player_body:
		player_body.player_calibrate_height = true


func _on_quit_button_button_pressed() -> void:
	get_tree().quit()
