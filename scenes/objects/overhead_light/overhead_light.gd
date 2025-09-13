@tool
class_name OverheadLight
extends XRToolsPickable

@export var good_pop_color: Color = Color("99ddff")
@export var bad_pop_color: Color = Color("ff9999")
@export var fade_timing: float = 5.0

@onready var spot_light_3d: SpotLight3D = %SpotLight3D
@onready var flourescent_light_sound: AudioStreamPlayer3D = $FlourescentLightSound
@onready var _tween: Tween = create_tween()

func _ready() -> void:
	update_lighting()


func update_lighting() -> void:
	spot_light_3d.light_color = good_pop_color if Player.is_currently_good_pop else bad_pop_color


func fade_in() -> Signal:
	_tween.tween_property(spot_light_3d, "light_energy", 1.0, fade_timing).from(0.0)
	flourescent_light_sound.play()
	return _tween.finished


func fade_out() -> Signal:
	_tween.tween_property(spot_light_3d, "light_energy", 0.0, fade_timing).from(1.0)
	return _tween.finished
