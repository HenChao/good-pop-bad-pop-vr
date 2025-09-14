@tool
class_name Level3
extends Node3D

signal level_complete(level_time: float)
signal level_failed

# gdlint: disable=max-line-length
const INTRO_SCENE: String = """
Mom::We followed up on the lead about the candy heist, and it lead us to this suspect.
Mom::He's going to be a handful. He's insisting on being called \"Mr. Big\" for some reason.
Dad::That's a new one. Anything we need to worry about?
Mom::No, I think Governor Granddad just let him watch too many mafia movies together.
Dad::Alright then. I'll see what he knows and report back.
"""

const FIRST_ROUND: String = """
Dad::So, what's this I hear about a candy heist?
Baby::Nice try, pop, but I wasn't born yesterday. More like a few months ago.
Dad::I see. So nothing you want to tell us?
Baby:Annoyed:Maybe I do, maybe I don't. What's it to ya, Pop?
"""

const SECOND_ROUND: String = """
Baby:Smiling:Alright, how about I make you an offer you can't refuse?
Dad::What did you have in mind?
Baby:Smiling:Maybe I've heard about a candy heist, sure. And maybe that information might be worth, lets say, one cookie?
"""

const SECOND_ROUND_INTERLUDE: String = """
Baby:Smiling:I changed my mind. Now I'm thinking it's worth two cookies instead.
Dad::Sorry kid, nothing personal.
"""

const SECOND_ROUND_TURNABOUT: String = """
Baby:Annoyed:I see you're one of those Untouchable Pops. Maybe we can make a reasonable deal.
Dad::Now we're getting somewhere.
"""

const END_INTERROGATION: String = """
Baby::Well well, this has been fun. A deal's a deal, I'll tell you what I know.
Dad::I'm glad you see reason.
Mom::As always, another great job with this case, Dad. I think there's a promotion in this for you this time.
Dad::Thanks, but no thanks, Chief. I was born to walk the beat.
"""

const OUT_OF_ENERGY: String = """
Baby::Well well, look at the time. I think I'm due for my nap time now.
Mom:Annoyed:He's a tough one, definitely. Must get it from your side of the family.
Dad::Sorry Chief. Timing is tight with this case, I definitely don't have a lot of time to play around.
"""

const TOO_AFRAID: String = """
Baby:Crying:You over played your hand this time, popper. I believe I'll ask for my lawyer now.
Mom:Annoyed:This was a big fish to have to let go, Dad. I'm not happy about this.
Dad::It'll take a lot to break him, and a bit more is enough for him to lawyer up.
Dad::I'll have to take my time and make sure I use the right toy for the job.
"""
# gdlint: enable=max-line-length

var script_manager: ScriptManager
var _current_round: int = 0
var _level_timer: float = 0.0
var _level_timer_active: bool = false

@onready var dad_speech_bubble: SpeechBubble = $InterrogationTable/SpeechBubble
@onready var mom_puter: ComputerScreen = %ComputerScreen
@onready var baby: Baby = %Baby
@onready var interrogation_table: InterrogationTable = %InterrogationTable
@onready var overhead_light: OverheadLight = %OverheadLight
@onready var intro_sfx: AudioStreamPlayer = %IntroSFX


func _ready() -> void:
	baby.visible = false
	baby.set_speaker_name("Mr. Big")


func _process(delta: float) -> void:
	if _level_timer_active:
		_level_timer += delta


func start_level() -> void:
	intro_sfx.play()
	await get_tree().create_timer(3.0).timeout
	await overhead_light.fade_in()
	# Play the intro dialogue.
	await script_manager.start_scene(INTRO_SCENE)
	# Bring in the suspect.
	baby.visible = true
	await script_manager.start_scene(FIRST_ROUND)
	# Start first round interrogation
	baby.start_interrogation()
	mom_puter.set_state(ComputerScreen.States.OFF_SCREEN)
	_setup_toys()
	_current_round = 1


func set_script_manager(sm: ScriptManager) -> void:
	script_manager = sm
	sm.set_actors(mom_puter, dad_speech_bubble, baby)


func set_player_reference(player: Player) -> void:
	player.player_persona_changed.connect(_on_pop_switch)


func _setup_toys() -> void:
	interrogation_table.initialize_toys()
	for zone in interrogation_table.toy_snap_zones:
		(zone.picked_up_object as Toy).pick_up_hint.connect(_on_toy_pickup)


func _on_pop_switch() -> void:
	overhead_light.update_lighting()


func _on_toy_pickup(hint: String) -> void:
	mom_puter.toy_hint.text = hint


func _on_baby_sufficiently_entertained() -> void:
	match _current_round:
		1:
			# Baby is happy enought, begin second round
			await script_manager.start_scene(SECOND_ROUND)
			# Set stats for the second round
			baby.current_mood = 50.0
			baby.happiness_gate = 90.0
			baby.fearfullness_gate = 5.0
			baby.max_energy = 120.0
			baby.current_energy = 120.0
			baby.start_interrogation()
			_current_round = 2
			_level_timer_active = true
			# Wait for happiness gate to be reached
		2:
			_level_timer_active = false
			await script_manager.start_scene(END_INTERROGATION)
			await overhead_light.fade_out()
			level_complete.emit(_level_timer)


func _on_baby_out_of_energy() -> void:
	await script_manager.start_scene(OUT_OF_ENERGY)
	await overhead_light.fade_out()
	level_failed.emit()


func _on_baby_too_afraid() -> void:
	await script_manager.start_scene(TOO_AFRAID)
	await overhead_light.fade_out()
	level_failed.emit()


func _on_baby_happiness_gate_reached() -> void:
	match _current_round:
		2:
			# Hit a wall in the interrogation
			baby.stop_interrogation()
			mom_puter.set_state(ComputerScreen.States.SILENT)
			await script_manager.start_scene(SECOND_ROUND_INTERLUDE)
			# Continue interrogation, need to be bad pop now
			mom_puter.set_state(ComputerScreen.States.OFF_SCREEN)
			baby.start_interrogation()
			# Wait for fearfullness gate to be reached


func _on_baby_fearfullness_gate_reached() -> void:
	match _current_round:
		2:
			baby.stop_interrogation()
			await script_manager.start_scene(SECOND_ROUND_TURNABOUT)
			# Continue interrogation, need to go back to good pop
			baby.happiness_gate = 110.0
			baby.start_interrogation()
