@tool
class_name ComputerScreen
extends Node3D

@onready var screen_mesh: MeshInstance3D = %ScreenMesh
@onready var mouth_sprite_3d: AnimatedSprite3D = %MouthSprite3D
@onready var eyes_sprite_3d: AnimatedSprite3D = %EyesSprite3D
@onready var speech_bubble: SpeechBubble = %SpeechBubble

enum STATES { OFF_SCREEN, SILENT, TALKING }
@export var current_state: STATES:
	set = set_state


func _ready() -> void:
	mouth_sprite_3d.play("talking")


func set_state(new_state: STATES) -> void:
	if new_state == current_state:
		return
	
	match new_state:
		STATES.OFF_SCREEN:
			screen_mesh.visible = false
			mouth_sprite_3d.visible = false
			eyes_sprite_3d.visible = false
			speech_bubble.visible = false
		STATES.SILENT:
			screen_mesh.visible = true
			mouth_sprite_3d.visible = false
			eyes_sprite_3d.visible = true
			speech_bubble.visible = false
		STATES.TALKING:
			screen_mesh.visible = true
			mouth_sprite_3d.visible = true
			eyes_sprite_3d.visible = true
			speech_bubble.visible = true
	current_state = new_state


func get_speech_bubble() -> SpeechBubble:
	return speech_bubble
