class_name Player
extends XROrigin3D

signal menu_button_hit

static var is_currently_good_pop: bool = true

@onready var left_function_pointer: XRToolsFunctionPointer = $XRController3D_Left/FunctionPointer
@onready var right_function_pointer: XRToolsFunctionPointer = $XRController3D_Right/FunctionPointer


func _on_function_pointer_pointing_event(event: Variant) -> void:
	if (event is XRToolsPointerEvent) and event.target.get_parent() is UIButton:
		var button_target: UIButton = event.target.get_parent()
		if event.event_type == event.Type.MOVED:
			button_target.update_cursor_position(event.last_position)
		elif event.event_type == event.Type.PRESSED:
			button_target.press_button()
			left_function_pointer.get_node("Laser").visible = false
			right_function_pointer.get_node("Laser").visible = false


func _on_xr_controller_3d_left_button_pressed(input_name: String) -> void:
	if input_name == "menu_button":
		menu_button_hit.emit()
