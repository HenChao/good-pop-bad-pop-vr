@tool
class_name Baby
extends Node3D

@onready var speech_bubble: SpeechBubble = %SpeechBubble

enum STATES { SILENT, TALKING }
@export var current_state: STATES:
	set = set_state


func _ready() -> void:
	set_state(STATES.SILENT)


func set_state(new_state: STATES) -> void:
	if new_state == current_state:
		return
	
	match new_state:
		STATES.SILENT:
			speech_bubble.visible = false
		STATES.TALKING:
			speech_bubble.visible = true
	current_state = new_state


func get_speech_bubble() -> SpeechBubble:
	return speech_bubble


func set_expression(expression: Dialogue.Expressions) -> void:
	match expression:
		Dialogue.Expressions.CRYING:
			pass
		Dialogue.Expressions.SCARED:
			pass
		Dialogue.Expressions.ANNOYED:
			pass
		Dialogue.Expressions.NEUTRAL:
			pass
		Dialogue.Expressions.SURPRISED:
			pass
		Dialogue.Expressions.SMILING:
			pass
		Dialogue.Expressions.JOYFUL:
			pass
