@tool
class_name UIButton
extends Node3D

signal button_pressed

@export var initial_text: String

var _shader_material: ShaderMaterial

@onready var cube: MeshInstance3D = $curved_box/Cube
@onready var button_label: Label3D = %ButtonLabel


func _ready() -> void:
	if initial_text:
		set_button_text(initial_text)
	_shader_material = cube.get_surface_override_material(0)


## Called when player hand is pointing to button.
## Sets the global position of the collision point to pass into shader.
func update_cursor_position(cursor_position: Vector3) -> void:
	var world_position: Vector3 = to_global(cursor_position)
	_shader_material.set_shader_parameter("CursorPosition", world_position)


## Called when player hand pressed a button from a controller.
func press_button() -> void:
	button_pressed.emit()


func set_button_text(text: String) -> void:
	button_label.text = text
