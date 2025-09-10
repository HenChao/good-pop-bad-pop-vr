@tool
class_name Toy
extends XRToolsPickable

## Emit when toy is activated by player. Value is based on if player is good pop or bad pop.
signal activated(value)

@export_group("Components Parameters")
@export var active_component: ActivateComponent
@export var audio_component: AudioComponent

@export_group("Timer Parameters")
@export var points_randomizer_timer: Timer
@export var timer_timeout: float = 30.0

@export_group("Points Parameters")
@export var entertained_point_min: float = 1.0
@export var entertained_point_max: float = 5.0
@export var afraid_point_min: float = -5.0
@export var afraid_point_max: float = -1.0

var _current_entertained_points: float = 0.0
var _current_afraid_points: float = 0.0


func _ready() -> void:
	assert(points_randomizer_timer, "No timer defined in %s of %s" % [name, get_parent().name])
	assert(active_component, "No Active Component defined in %s of %s" % [name, get_parent().name])
	assert(audio_component, "No Audio Component defined in %s of %s" % [name, get_parent().name])
	_set_random_points_value()
	
	# Setup timer to periodically randomize the points value, to keep folks on their toes.
	points_randomizer_timer.timeout.connect(func():
		_set_random_points_value())
	points_randomizer_timer.one_shot = false
	points_randomizer_timer.start(timer_timeout)
	
	active_component.activated.connect(_on_toy_activation)


## Helper function to randomize both the entertained and afraid point values.
func _set_random_points_value() -> void:
	_current_entertained_points = randf_range(entertained_point_min, entertained_point_max)
	_current_afraid_points = randf_range(afraid_point_min, afraid_point_max)


func _on_toy_activation() -> void:
	activated.emit(_current_entertained_points if Player.is_currently_good_pop else _current_afraid_points)
	audio_component.play_sound()
