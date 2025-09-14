class_name ActivateComponent
extends Node3D
## Toy component which handles player interaction logic.
## Boolean parameters control which type of interaction is listened for by the toy.

## Emitted when toy should be considered activated for scoring.
## Intensity value will help determine haptic feedback value.
signal activated(intensity: float)
## Emitted by some toys to stop scoring early.
signal deactivate

@export_group("Activation Type")
## Toy is activated by squeezing controller trigger.
@export var is_squeezed: bool = false
## Toy is activated by flipping object upside down.
@export var is_flipped: bool = false
## Toy is activated by shaking object quickly.
@export var is_shaken: bool = false
## Toy is activated when in a specific area.
@export var is_in_area: bool = false

# Internal variables to calculate acceleration for shaking interaction.
var _parent_last_global_position: Vector3
var _last_velocity: Vector3 = Vector3.ZERO
var _last_velocity_delta_magnitude: float = 0.0
## Acceleration threshold value at which the toy is considered shaken.
var _acceleration_threshold: float = 0.5

## Tracks if toy is held in specific area for is_in_area activation.
var _held_in_area: bool = false

@onready var debounce_timer: Timer = %DebounceTimer
@onready var continuous_timer: Timer = %ContinuousTimer


func _ready() -> void:
	## Connect to controllers to listen for player input
	var controllers: Array[Node] = get_tree().get_nodes_in_group("XRController")
	if controllers.size() > 0:
		for controller in controllers:
			(controller as XRController3D).input_float_changed.connect(_on_controller_input_trigger)
	_parent_last_global_position = get_parent().global_position


func _physics_process(delta: float) -> void:
	if is_flipped and _is_upside_down():
		_debounce_signal("upside_down")
	if is_shaken and _is_shaking(delta):
		_debounce_signal("shaking")


func _on_controller_input_trigger(input_name: String, input_value: float) -> void:
	if is_squeezed and input_name == "trigger" and input_value >= 0.5:
		activated.emit(input_value)


func _on_activation_area_area_entered(area: Area3D) -> void:
	if is_in_area and area.is_in_group("PlayerMouth"):
		_held_in_area = true
		_continuous_signal()


func _on_activation_area_area_exited(area: Area3D) -> void:
	if is_in_area and area.is_in_group("PlayerMouth"):
		_held_in_area = false
		deactivate.emit()


func _is_upside_down() -> bool:
	return get_parent().global_rotation_degrees.z <= -110 or get_parent().global_rotation_degrees.z >= 110


## Helper function to determine if object is being shaken.
func _is_shaking(delta: float) -> bool:
	var velocity: Vector3 = (get_parent().global_position - _parent_last_global_position) / delta
	var current_velocity_delta_magnitude: float = (_last_velocity - velocity).length_squared()
	var current_acceleration: float = (
		abs(_last_velocity_delta_magnitude - current_velocity_delta_magnitude) / delta
	)
	_last_velocity = velocity
	_last_velocity_delta_magnitude = current_velocity_delta_magnitude
	_parent_last_global_position = get_parent().global_position
	return current_acceleration >= _acceleration_threshold


## Helper function to avoid emitting the signal too often.
## type = [shaking, upside_down]
## Emit the last recorded velcity if shaking, 1.0 otherwise.
func _debounce_signal(type: String) -> void:
	if debounce_timer.is_stopped():
		debounce_timer.start()
		activated.emit(_last_velocity_delta_magnitude if type == "shaking" else 1.0)


func _continuous_signal() -> void:
	if continuous_timer.is_stopped():
		continuous_timer.start()
		activated.emit(1.0)


func _on_continuous_timer_timeout() -> void:
	if _held_in_area:
		_continuous_signal()
