class_name InterrogationTable
extends StaticBody3D
## Interrogation table object in game. Contains snap zones binding toys to specific areas.
## Also anchors the player speech bubble in game.

@export var toys_array: Array[PackedScene] = []

@onready var toy_snap_zone_1: XRToolsSnapZone = %ToySnapZone1
@onready var toy_snap_zone_2: XRToolsSnapZone = %ToySnapZone2
@onready var toy_snap_zone_3: XRToolsSnapZone = %ToySnapZone3
@onready var toy_snap_zones: Array[XRToolsSnapZone] = [%ToySnapZone1, %ToySnapZone2, %ToySnapZone3]
@onready var toys_tree: Node3D = %ToysTree
@onready var speech_bubble: SpeechBubble = %SpeechBubble


func _ready() -> void:
	speech_bubble.visible = false
	if toys_array.size() < toy_snap_zones.size():
		assert(false, "Not enough toys assigned to interrogation table in %s" % get_parent().name)


func initialize_toys() -> void:
	toys_array.shuffle()
	# Use a deep-copy of the toys array, rather than the one setup in the scene.
	# This way, if the player needs to replay the level, we always start with a fresh set of toys.
	var copy_toys_array = toys_array.duplicate(true)
	for zone in toy_snap_zones:
		var toy: Toy = (copy_toys_array.pop_front() as PackedScene).instantiate()
		toys_tree.add_child(toy)
		zone.initial_object = toy.get_path()
		zone.pick_up_object(toy)
		toy.assign_snap_zone(zone)
