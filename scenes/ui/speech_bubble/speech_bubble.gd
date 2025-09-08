@tool
class_name SpeechBubble
extends Node3D

signal confirmed_input

@export var speaker_name: String:
	set = set_speaker_name
@export var example_text: String:
	set = set_text
@export var billboard: bool = true

@onready var speaker_label: Label3D = %SpeakerLabel
@onready var text_label: Label3D = %TextLabel
@onready var cube: MeshInstance3D = $curved_box/Cube


func _physics_process(_delta: float) -> void:
	if billboard:
		var camera: Camera3D = get_viewport().get_camera_3d()
		if camera:
			look_at(camera.global_position, Vector3.UP, true)


func set_text(line: String) -> void:
	example_text = line
	if text_label:
		text_label.text = example_text


func set_speaker_name(speaker: String) -> void:
	speaker_name = speaker
	if speaker_label:
		speaker_label.text = speaker_name


func on_controller_input(input_name: String) -> void:
	if input_name == "ax_button":
		confirmed_input.emit()
