@tool
class_name OverheadLight
extends XRToolsPickable

@export var good_pop_color: Color = Color("99ddff")
@export var bad_pop_color: Color = Color("ff9999")

@onready var spot_light_3d: SpotLight3D = %SpotLight3D


func _ready() -> void:
	update_lighting()


func update_lighting() -> void:
	spot_light_3d.light_color = good_pop_color if Player.is_currently_good_pop else bad_pop_color
