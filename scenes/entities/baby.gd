@tool
class_name Baby
extends Node3D

@onready var speech_bubble: SpeechBubble = %SpeechBubble
@onready var eyes: Label3D = %Eyes
@onready var mouth: Label3D = %Mouth

enum States { SILENT, TALKING }
@export var current_state: States:
	set = set_state
@export var current_expression: Dialogue.Expressions:
	set = set_expression

var _speech_pattern: Array[String] = ["-", "=", "o", "~"]
var _speech_cycle: int = 0
var _speech_time: float = 0.0
var _speech_rate: float = 1.0

func _ready() -> void:
	set_state(States.SILENT)


func _physics_process(delta: float) -> void:
	if current_state == States.TALKING:
		_speech_time += delta
		if _speech_time >= _speech_rate:
			_speech_time = 0.0
			mouth.text = _speech_pattern[_speech_cycle]
			_speech_cycle = (_speech_cycle + 1) % _speech_pattern.size()


func set_state(new_state: States) -> void:
	if new_state == current_state:
		return
	
	match new_state:
		States.SILENT:
			speech_bubble.visible = false
			set_expression(current_expression)
		States.TALKING:
			speech_bubble.visible = true
	current_state = new_state


func get_speech_bubble() -> SpeechBubble:
	return speech_bubble


func set_expression(expression: Dialogue.Expressions) -> void:
	match expression:
		Dialogue.Expressions.CRYING:
			eyes.text  = "><"
			mouth.text = "~"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.SCARED:
			eyes.text  = "~~"
			mouth.text = "-"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.ANNOYED:
			eyes.text  = "¬¬"
			mouth.text = "-"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.NEUTRAL:
			eyes.text  = "--"
			mouth.text = "-"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.SURPRISED:
			eyes.text  = "oo"
			mouth.text = "o"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.SMILING:
			eyes.text  = "^^"
			mouth.text = ")"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, -90)
		Dialogue.Expressions.JOYFUL:
			eyes.text  = "><"
			mouth.text = "D"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, -90)
	current_expression = expression
