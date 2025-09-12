class_name InterrogationTable
extends StaticBody3D

@export var toys_array: Array[PackedScene] = []

@onready var toy_snap_zone_1: XRToolsSnapZone = %ToySnapZone1
@onready var toy_snap_zone_2: XRToolsSnapZone = %ToySnapZone2
@onready var toy_snap_zone_3: XRToolsSnapZone = %ToySnapZone3
@onready var toy_snap_zones: Array[XRToolsSnapZone] = [
	%ToySnapZone1, %ToySnapZone2, %ToySnapZone3
]
@onready var toys_tree: Node3D = %ToysTree


func _ready() -> void:
	if toys_array.size() < toy_snap_zones.size():
		assert(
			false,
			"Not enough toys assigned to interrogation table in %s" % get_parent().name
		)

func initialize_toys() -> void:
	toys_array.shuffle()
	for zone in toy_snap_zones:
		var toy: Toy = (toys_array.pop_front() as PackedScene).instantiate()
		toys_tree.add_child(toy)
		zone.initial_object = toy.get_path()
		zone.pick_up_object(toy)
		toy.assign_snap_zone(zone)
