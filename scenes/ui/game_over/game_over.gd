class_name GameOver
extends Node3D

signal restart_pressed

const ANIMATION_TIMING: float = 3.0
# gdlint: disable=max-line-length
const HINT_ARRAY: Array[String] = [
	"Keep an eye on the suspect's expression to see if they're happy or scared.",
	"Try different toys if it seems like you're progressing too slowly.",
	"Avoid using a toy that gets the suspect scared too fast as Bad Pop.",
	"If you're not sure how a toy works, take a look at the monitor when you pick it up.",
	"The rubber duck will quack on trigger pull.",
	"The cow tow will moo when it's flipped upside down.",
	"Shake the rattle to get the suspect's attention.",
	"Bring the kazoo up to your lips to make a sound.",
	"Toys are only effective if the suspect is paying attention to it. Make sure to bring it up to their range of vision first."
]
# gdlint: enable=max-line-length

@onready var game_over: Sprite3D = %GameOver
@onready var restart_button: UIButton = %RestartButton
@onready var quit_button: UIButton = %QuitButton
@onready var hint_label: Label3D = %HintLabel
@onready var _tween: Tween = create_tween()


func _ready() -> void:
	game_over.modulate.a = 0
	restart_button.set_alpha(0)
	quit_button.set_alpha(0)
	restart_button.enabled = false
	quit_button.enabled = false
	hint_label.visible = false
	_animate_menu_in()


func _animate_menu_in() -> void:
	_tween.set_parallel()
	_tween.set_ease(Tween.EASE_IN)
	_tween.tween_property(game_over, "modulate:a", 1, ANIMATION_TIMING)
	_tween.tween_method(restart_button.set_alpha, 0.0, 0.3, ANIMATION_TIMING)
	_tween.tween_method(quit_button.set_alpha, 0.0, 0.3, ANIMATION_TIMING)
	_tween.tween_callback(
		func():
			hint_label.text = HINT_ARRAY.pick_random()
			hint_label.visible = true
			restart_button.enabled = true
			quit_button.enabled = true
	)


func _on_quit_button_button_pressed() -> void:
	get_tree().quit()


func _on_restart_button_button_pressed() -> void:
	restart_pressed.emit()
