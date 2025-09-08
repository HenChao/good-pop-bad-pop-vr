class_name Player
extends XROrigin3D


func _on_function_pointer_pointing_event(event: Variant) -> void:
	if (event is XRToolsPointerEvent) and (event as XRToolsPointerEvent).target is UIButton:
		if (event.event_type == event.Type.MOVED):
			event.target.update_cursor_position(event.last_position)
		elif (event.event_type == event.Type.PRESSED):
			event.target.press_button()
