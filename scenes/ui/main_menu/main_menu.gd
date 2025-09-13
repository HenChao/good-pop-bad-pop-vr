@tool
class_name MainMenu
extends Node3D

@export var player_body: XRToolsPlayerBody
@export var level_manager: LevelManager

@onready var logo: Sprite3D = %Logo
@onready var start_button: UIButton = %StartButton
@onready var set_height_button: UIButton = %SetHeightButton
@onready var quit_button: UIButton = %QuitButton
@onready var no_highlight: Sprite3D = %NoHighlight
@onready var _tween: Tween = create_tween()


func _ready() -> void:
	assert(player_body, "Player Body Node not assigned.")
	assert(level_manager, "Level manager node not assigned.")
	logo.modulate.a = 0.0
	start_button.set_alpha(0.0)
	start_button.enabled = false
	set_height_button.set_alpha(0.0)
	set_height_button.enabled = false
	quit_button.set_alpha(0.0)
	quit_button.enabled = false
	_play_intro_animation()


func _play_intro_animation() -> void:
	_tween.tween_property(no_highlight, "position", Vector3(0.0, 2.8, 0.0), 5.0)
	_tween.tween_property(logo, "modulate:a", 1.0, 1.0)
	_tween.tween_property(no_highlight, "modulate:a", 0, 1.0)
	# Fade in buttons
	_tween.tween_method(start_button.set_alpha, 0.0, 0.3, 2.0)
	_tween.parallel().tween_method(set_height_button.set_alpha, 0.0, 0.3, 2.0)
	_tween.parallel().tween_method(quit_button.set_alpha, 0.0, 0.3, 2.0)
	_tween.tween_callback(
		func():
			start_button.enabled = true
			set_height_button.enabled = true
			quit_button.enabled = true
	)


func _on_start_button_button_pressed() -> void:
	level_manager.set_level(LevelManager.Levels.TUTORIAL_LEVEL)


func _on_set_height_button_button_pressed() -> void:
	if player_body:
		player_body.player_calibrate_height = true


func _on_quit_button_button_pressed() -> void:
	get_tree().quit()
