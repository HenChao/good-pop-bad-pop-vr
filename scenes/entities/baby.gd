@tool
class_name Baby
extends Node3D

@onready var speech_bubble: SpeechBubble = %SpeechBubble

enum STATES { SILENT, TALKING }
@export var current_state: STATES:
	set = set_state


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
