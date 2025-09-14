class_name Victory
extends Node3D
## Victory menu screen, displayed when player successfully complets an interview.
## Shows the amount of time taken in the last level. Also provides player a button
## to continue to the next level.

signal next_level_pressed

const ANIMATION_TIMING: float = 3.0

@onready var victory: Sprite3D = %Victory
@onready var time_label: Label3D = %TimeLabel
@onready var next_level_button: UIButton = %NextLevelButton
@onready var quit_button: UIButton = %QuitButton
@onready var _tween: Tween = create_tween()


func _ready() -> void:
	victory.modulate.a = 0
	next_level_button.set_alpha(0)
	quit_button.set_alpha(0)
	next_level_button.enabled = false
	quit_button.enabled = false
	_animate_menu_in()


func _animate_menu_in() -> void:
	_tween.set_parallel()
	_tween.tween_property(victory, "modulate:a", 1, ANIMATION_TIMING)
	_tween.set_ease(Tween.EASE_IN)
	_tween.tween_method(next_level_button.set_alpha, 0.0, 0.3, ANIMATION_TIMING)
	_tween.tween_method(quit_button.set_alpha, 0.0, 0.3, ANIMATION_TIMING)
	_tween.tween_callback(
		func():
			next_level_button.enabled = true
			quit_button.enabled = true
	)


func set_level_time(timing: float) -> void:
	var timing_string: String = str(timing)
	var split_timing_string: PackedStringArray = timing_string.split(".")
	time_label.text = "Interrogation Time: %s.%s seconds" % [
		split_timing_string[0],
		split_timing_string[1].substr(0, 1)
		]


func _on_next_level_button_button_pressed() -> void:
	next_level_pressed.emit()


func _on_quit_button_button_pressed() -> void:
	get_tree().quit()
