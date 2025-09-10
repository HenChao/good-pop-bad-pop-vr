class_name Player
extends XROrigin3D

static var xr_controller_3d_left: XRController3D
static var xr_controller_3d_right: XRController3D
static var is_currently_good_pop: bool = true


func _ready() -> void:
	xr_controller_3d_left = %XRController3D_Left
	xr_controller_3d_right = %XRController3D_Right


func _on_function_pointer_pointing_event(event: Variant) -> void:
	if (event is XRToolsPointerEvent) and event.target.get_parent() is UIButton:
		var button_target: UIButton = event.target.get_parent()
		if event.event_type == event.Type.MOVED:
			button_target.update_cursor_position(event.last_position)
		elif event.event_type == event.Type.PRESSED:
			button_target.press_button()


static func get_controllers() -> Array[XRController3D]:
	return (
		[xr_controller_3d_left, xr_controller_3d_right]
		if (xr_controller_3d_left and xr_controller_3d_right)
		else []
	)
