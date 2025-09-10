class_name ActivateComponent
extends Node3D

signal activated

@onready var debounce_timer: Timer = %DebounceTimer
@onready var accelerometer: RigidBody3D = %Accelerometer

@export_group("Activation Type")
@export var is_squeezed: bool = false
@export var is_flipped: bool = false
@export var is_shaken: bool = false
@export var is_in_area: bool = false

# Internal variables to calculate acceleration
var _last_velocity_magnitude: float = 0.0
## Acceleration threshold value at which the toy is considered shaken.
var _acceleration_threshold: float = 0.5

func _ready() -> void:
	## Connect to controllers to listen for player input
	var controllers: Array[XRController3D] = Player.get_controllers()
	if controllers.size() > 0:
		for controller in controllers:
			controller.input_float_changed.connect(_on_controller_input_grip)


func _physics_process(delta: float) -> void:
	if is_flipped and _is_upside_down():
		_debounce_signal()
	if is_shaken and _is_shaking(delta):
		_debounce_signal()


func _on_controller_input_grip(input_name: String, input_value: float) -> void:
	if is_squeezed and input_name == "grip" and input_value >= 0.5:
		activated.emit()


func _on_activation_area_area_entered(area: Area3D) -> void:
	if is_in_area and area.is_in_group("PlayerMouth"):
		activated.emit()


func _is_upside_down() -> bool:
	return global_rotation_degrees.x <= -110 or global_rotation_degrees.x >= 110


## Helper function to determine if object is being shaken.
func _is_shaking(delta: float) -> bool:
	var current_velocity_magnitude: float = accelerometer.linear_velocity.length_squared()
	var current_acceleration: float = abs(_last_velocity_magnitude - current_velocity_magnitude) / delta
	_last_velocity_magnitude = current_velocity_magnitude
	return current_acceleration >= _acceleration_threshold


## Helper function to avoid emitting the signal too often.
func _debounce_signal() -> void:
	if debounce_timer.is_stopped():
		debounce_timer.start()
		activated.emit()
