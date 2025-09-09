class_name Player
extends XROrigin3D


func _on_function_pointer_pointing_event(event: Variant) -> void:
	if (event is XRToolsPointerEvent) and event.target.get_parent() is UIButton:
		var button_target: UIButton = event.target.get_parent()
		if (event.event_type == event.Type.MOVED):
			button_target.update_cursor_position(event.last_position)
		elif (event.event_type == event.Type.PRESSED):
			button_target.press_button()
