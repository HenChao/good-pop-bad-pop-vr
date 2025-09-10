class_name HapticsComponent
extends Node3D

@export var rumble_event: XRToolsRumbleEvent
## Set a constant intensity for rumble magnitude if value is greater than 0.
@export_range(0, 1, 0.10) var static_intensity: float


func rumble_controller(
	controller: XRController3D, intensity: float, duration: float = 300.0
) -> void:
	if not is_zero_approx(static_intensity):
		rumble_event.magnitude = static_intensity
	else:
		rumble_event.magnitude = clamp(intensity, 0.1, 1.0)
	rumble_event.duration_ms = duration
	XRToolsRumbleManager.add(controller.name, rumble_event, [controller])
