@tool
class_name Level2
extends Node3D

signal level_complete(level_time: float)
signal level_failed

# gdlint: disable=max-line-length
const INTRO_SCENE: String = """
Mom::This is a big one, Dad. Our suspect is thought to be the serial vandal, Bonksky.
Dad::The one who's been writting graffiti in the hallway walls? I know they're a big hit with the rest of the kids.
Mom::Yep, that's the one. She was caught tonight tagging the nursery room door with a new message.
Mom::\"Down with bedtimes, up with ice cream.\""
Dad::Catchy. Has a certain type of poetry to it.
Mom::Poetic or not, it doesn't help to rile up the other kids like that.
Mom::We caught her red-handed with this last one, but we need you to get her to confess to all the other ones.
Dad::I'm on it.
"""

const FIRST_ROUND: String = """
Dad::I expected this from the boys, but as the only girl in the family, you should know better.
Baby:Annoyed:Please. I was framed! I found that marker next to the graffiti and I just happened to pick it up.
Dad::I've seen you leave things in your diaper less stinky than that lie.
"""

const SECOND_ROUND: String = """
Baby:Smiling:Well, that was fun, but if there's nothing else, I want to go back to play.
Dad::Sorry princess, but we're not done here.
"""

const SECOND_ROUND_INTERLUDE: String = """
Baby::But I thought I was your favorite? Don't I get pretty pretty princess immunity?
Dad::It's just been revoked.
"""

const SECOND_ROUND_TURNABOUT: String = """
Baby:Annoyed:Alright alright, if I tell you about a big candy heist that's being planned, will you let me go?
Dad::Seeing as you're in a sharing-is-caring mood, I might consider it.
"""

const END_INTERROGATION: String = """
Baby::Okay, fine, I admit to it. I am the one known as Bonksky.
Baby::If nothing else, I'll finally get the recognition I deserve.
Dad::The only thing you deserve is a long time-out.
Mom::Great job Dad! They'll be talking about this one in the PTA for sure.
Dad::It's not about the glory for me. I'm just glad to see the streets clean of loose Lego bricks.
Mom::The heist that she mentioned concerns me. I haven't heard of anything close to this being planned.
Mom::If it's true, then it means there's a big player out there, operating right under our noses.
Dad::Then there's no time to waste. Lets roll.
"""

const OUT_OF_ENERGY: String = """
Baby::Daddy, it's getting late. Can I get my juice box now?
Mom:Annoyed:What happened, Dad? You seem off on this one.
Dad::Sorry Chief. It looks like she's not as energetic than her brothers.
Dad::Next time, I'll have to keep a close eye on her energy levels and move fast.
"""

const TOO_AFRAID: String = """
Baby:Crying:WAAAA!!! Why are you so mean to me?!?!?! MOOOOMMMMMM!!!
Mom:Annoyed:What are you doing, Dad? You're turning into a loose cannon. Turn in your badge and gun, now.
Dad::You mean my beer koozie and bug-a-salt?
Mom:Annoyed:Whatever.
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
	baby.set_speaker_name("Alice")


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
			baby.fearfullness_gate = 30.0
			baby.max_energy = 150.0
			baby.current_energy = 150.0
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
