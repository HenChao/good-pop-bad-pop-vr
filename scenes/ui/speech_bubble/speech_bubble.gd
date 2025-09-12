@tool
class_name SpeechBubble
extends Node3D

signal confirmed_input

const ANIMATION_RATE: float = 1.0

@export var speaker_name: String:
	set = set_speaker_name
@export var example_text: String:
	set = set_text
@export var billboard: bool = true
@export var display_press_to_continue_prompt: bool = true

var _animation_cycle: int = 1
var _time_last_updated: float = 0.0

@onready var cube: MeshInstance3D = $curved_box/Cube
@onready var speaker_label: Label3D = %SpeakerLabel
@onready var text_label: Label3D = %TextLabel
@onready var press_to_continue_label: Label3D = %PressToContinueLabel


func _physics_process(delta: float) -> void:
	if billboard:
		var camera: Camera3D = get_viewport().get_camera_3d()
		if camera:
			look_at(camera.global_position, Vector3.UP, true)
	_time_last_updated += delta
	if _time_last_updated >= ANIMATION_RATE:
		_time_last_updated = 0.0
		press_to_continue_label.text = "Press a/x to continue"
		for num_of_periods in _animation_cycle:
			press_to_continue_label.text += "."
		_animation_cycle = (_animation_cycle + 1) % 4


func set_text(line: String) -> void:
	example_text = line
	if text_label:
		text_label.text = example_text


func set_speaker_name(speaker: String) -> void:
	speaker_name = speaker
	if speaker_label:
		speaker_label.text = speaker_name


func on_controller_input(input_name: String) -> void:
	if not get_tree().paused and input_name == "ax_button":
		confirmed_input.emit()
