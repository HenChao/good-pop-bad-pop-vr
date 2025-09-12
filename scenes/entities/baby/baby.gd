@tool
class_name Baby
extends Node3D

signal out_of_energy
signal too_afraid
signal sufficiently_entertained

enum States { SILENT, TALKING }

@export var current_state: States:
	set = set_state
@export var current_expression: Dialogue.Expressions:
	set = set_expression

@export_group("Baby stats")
@export var current_mood: float = 50.0
@export var interrogation_mood_threshold: float = 95.0
@export var max_energy: float = 100.0
@export var current_energy: float = 100.0
@export var base_energy_rate: float = -5.0
@export var entertained_energy_rate: float = 2.0
@export var fearful_energy_rate: float = -2.0
@export var is_being_interrogated: bool = false

var _is_entertained: bool = false
var _is_afraid: bool = false

var _speech_pattern: Array[String] = ["-", "=", "o", "~"]
var _speech_cycle: int = 0
var _speech_time: float = 0.0
var _speech_rate: float = 1.0

var _tracked_toy_area: Area3D
var _update_tracking_timing: float = 0.0
var _update_tracking_period: float = 2.0

@onready var speech_bubble: SpeechBubble = %SpeechBubble
@onready var head_mesh: MeshInstance3D = %HeadMesh
@onready var eyes: Label3D = %Eyes
@onready var mouth: Label3D = %Mouth
@onready var energy_bar: MeshInstance3D = %EnergyBar
@onready var energy_bar_shader_material: ShaderMaterial


func _ready() -> void:
	set_state(States.SILENT)
	energy_bar.visible = false
	energy_bar_shader_material = energy_bar.get_surface_override_material(0)


func _physics_process(delta: float) -> void:
	if current_state == States.TALKING:
		_speech_time += delta
		if _speech_time >= _speech_rate:
			_speech_time = 0.0
			mouth.text = _speech_pattern[_speech_cycle]
			_speech_cycle = (_speech_cycle + 1) % _speech_pattern.size()

	if Engine.is_editor_hint():
		return

	_update_tracking_timing += delta
	if _update_tracking_timing >= _update_tracking_period:
		_update_tracking_timing = 0.0
		# Look at dad, unless held toy enters field of view
		var look_at_target_position: Vector3 = (
			_tracked_toy_area.global_position
			if _tracked_toy_area
			else get_viewport().get_camera_3d().global_position
		)
		head_mesh.look_at(look_at_target_position, Vector3.UP, true)

	# Only perform next block if is actively interrogated.
	if not is_being_interrogated:
		return
	# Recalculate mood based on entertainment level
	_determine_mood()

	# Calculate energy level
	var energy_modifier: float = base_energy_rate
	energy_modifier += entertained_energy_rate if _is_entertained else 0.0
	energy_modifier += fearful_energy_rate if _is_afraid else 0.0
	current_energy += energy_modifier * delta
	_update_energy_bar()
	if current_energy <= 0.0:
		out_of_energy.emit()
		stop_interrogation()


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
			eyes.text = "><"
			mouth.text = "~"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.SCARED:
			eyes.text = "~~"
			mouth.text = "-"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.ANNOYED:
			eyes.text = "¬¬"
			mouth.text = "-"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.NEUTRAL:
			eyes.text = "--"
			mouth.text = ")"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, -90)
		Dialogue.Expressions.SURPRISED:
			eyes.text = "oo"
			mouth.text = "o"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, 0)
		Dialogue.Expressions.SMILING:
			eyes.text = "^^"
			mouth.text = ")"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, -90)
		Dialogue.Expressions.JOYFUL:
			eyes.text = "><"
			mouth.text = "D"
			mouth.font_size = 16
			mouth.rotation_degrees = Vector3(0, 0, -90)
	current_expression = expression


func start_interrogation() -> void:
	is_being_interrogated = true
	energy_bar.visible = true


func stop_interrogation() -> void:
	is_being_interrogated = false
	energy_bar.visible = false


func _determine_mood() -> void:
	if current_mood <= 0.0:
		too_afraid.emit()
		stop_interrogation()
		return
	if current_mood >= interrogation_mood_threshold:
		sufficiently_entertained.emit()
		stop_interrogation()
	elif current_mood >= 100:
		current_mood = 100  # Set hard limit for current_mood

	if _is_between(current_mood, 0.0, 10.0):
		set_expression(Dialogue.Expressions.CRYING)
	elif _is_between(current_mood, 10.0, 25.0):
		set_expression(Dialogue.Expressions.SCARED)
	elif _is_between(current_mood, 25.0, 40.0):
		set_expression(Dialogue.Expressions.ANNOYED)
	elif _is_between(current_mood, 40.0, 60.0):
		set_expression(Dialogue.Expressions.NEUTRAL)
	elif _is_between(current_mood, 60.0, 75.0):
		set_expression(Dialogue.Expressions.SURPRISED)
	elif _is_between(current_mood, 75.0, 85.0):
		set_expression(Dialogue.Expressions.SMILING)
	elif _is_between(current_mood, 85.0, 100.0):
		set_expression(Dialogue.Expressions.JOYFUL)


## Helper function to determine if value is between lower (exclusive) and upper (inclusive)
func _is_between(value: float, lower: float, upper: float) -> bool:
	return value > lower and value <= upper


func _update_energy_bar() -> void:
	energy_bar_shader_material.set_shader_parameter("EnergyPercentage", current_energy / max_energy)


func _on_field_of_view_area_entered(area: Area3D) -> void:
	_tracked_toy_area = area


func _on_field_of_view_area_exited(_area: Area3D) -> void:
	_tracked_toy_area = null
