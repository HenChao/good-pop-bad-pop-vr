@tool
class_name EndGame
extends Node3D

signal level_complete(level_time: float)
signal level_failed

# gdlint: disable=max-line-length
const FINAL_SCENE: String = """
Mom::Well Dad, we did good today. It wasn't easy, but you closed all your cases.
Dad::Yep, the house is safe from those kids for another day.
Mom::Get some rest now. You've got about another two hours before those kids wake up.
"""
# gdlint: enable=max-line-length

var script_manager: ScriptManager

@onready var dad_speech_bubble: SpeechBubble = $InterrogationTable/SpeechBubble
@onready var mom_puter: ComputerScreen = %ComputerScreen
@onready var baby: Baby = %Baby
@onready var interrogation_table: InterrogationTable = %InterrogationTable
@onready var overhead_light: OverheadLight = %OverheadLight
@onready var credits: Label3D = %Credits


func _ready() -> void:
	baby.visible = false


func start_level() -> void:
	await get_tree().create_timer(3.0).timeout
	await overhead_light.fade_in()
	# Play the final dialogue.
	await script_manager.start_scene(FINAL_SCENE)
	mom_puter.set_state(ComputerScreen.States.OFF_SCREEN)
	
	var tween: Tween = create_tween()
	tween.tween_property(credits, "position:y", 3, 20)
	tween.tween_property(credits, "modulate:a", 0.0, 2)
	await tween.finished
	await overhead_light.fade_out()
	level_complete.emit(0.0)


func set_script_manager(sm: ScriptManager) -> void:
	script_manager = sm
	sm.set_actors(mom_puter, dad_speech_bubble, baby)


func set_player_reference(player: Player) -> void:
	player.player_persona_changed.connect(_on_pop_switch)


func _on_pop_switch() -> void:
	overhead_light.update_lighting()
