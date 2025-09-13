@tool
class_name TutorialLevel
extends Node3D

signal level_complete(level_time: float)
signal level_failed

# gdlint: disable=max-line-length
const INTRO_SCENE: String = """
Mom::Well Dad, it's shaping up to be another busy night tonight.
Dad::It always is around here. Sometimes I wonder if what we do makes any difference.
Mom::Of course it does. Never forget that we're the last line between order and chaos.
Dad::You're right of course. So what do you have for me first?
Mom::I know it's been a while, so we'll start off with a simple case.
Mom::I'll also walk you through the process step-by-step, just as a quick refresher.
Dad::Sounds good. I appreciate the help.
Mom::Don't mention it. I'm sure it'll be like riding a bike.
Mom::Our first case is a 211, straight B and E. It looks like someone stole a cookie from the cookie jar.
Mom::We'll bring the suspect into the room. Your job is to get a confession from them.
Mom::Start by talking with them, get their side of the story. Then press them for more information.
Mom::Note that you have only a small window of time to get a confession.
Mom::If you take too long, then they can get bored and sleepy, and we'll have to put them down for a nap.
Mom::The interrogation room can be a scary place, so try and make them feel comfortable.
Mom::We'll have some toys available on the table for you to use to soothe them.
Dad::Sounds good, I think I'm ready to start.
Mom::Good. We'll bring in the suspect now.
"""

const FIRST_ROUND: String = """
Dad::Well well well, I had a feeling I'd see you in here again one of these days.
Baby:Scared:I know I've been in trouble before, but I didn't do anything!
Dad::We'll see about that. What do you know about the cookie from the cookie jar?
Baby:Annoyed:Cookie? What's a cookie? Never heard of any cookies.
"""

const SECOND_ROUND: String = """
Baby:Smiling:Oh, the COOKIE jar you said? Yes I think I remembered seeing someone around the jar tonight.
Dad::Who did you see?
Baby:Smiling:It was Jerry, the kitchen mouse. He must have taken the cookie...
"""

const SECOND_ROUND_INTERLUDE: String = """
Dad::Chief, I've got a problem here. No matter what I do, I'm not getting any further with the interrogation.
Mom::Hmm, it might be time for a shift in strategy.
Mom::Rather than keeping the suspect relaxed, try and apply some pressure to see if they'll break.
Mom::Raise your hands up to your eyes and play peek-a-boo. When the suspect sees you again, they'll see someone else.
Mom::Play the role of the bad pop and be more aggressive with your questioning and play time.
Mom::Just remember, don't take it too far, or else they'll call for their lawyer.
Mom::Once you think you've gotten them sufficiently scared, then play peek-a-boo again to switch back to good pop.
Mom::You should then be able to play with them and get them back to a good spot.
Dad::Alright Chief, I'll give it a shot.
"""

const SECOND_ROUND_TURNABOUT: String = """
Baby::Dad, is it getting hot in here, or is it just me?
Dad::Must be the guilt eating you up inside. Think you're ready to talk now?
"""

const END_INTERROGATION: String = """
Baby:Surprised:Oh, you know what, I just remembered. I did eat a cookie today!
Baby:Joyful:I didn't realize it was from the cookie jar you were asking about. I had my eyes closed while I was getting it.
Dad::A likely story, but that won't save you from your punishment. You're in for a time-out now mister.
Baby:Annoyed:You can send me away, but I'll be back on the streets in no time again.
Mom::Well done Dad, you haven't missed a beat.
Dad::Thanks Chief, it was a pretty straightforward case, but sometimes that's just how the cookie crumbles.
"""

const OUT_OF_ENERGY: String = """
Baby:Annoyed:That was fun Dad, but I think I hear the blankie calling my name.
Mom::Good try Dad, but you ran out of time. Chances are we'll never find out who took the cookie now.
Dad::Hmm, I'll keep in mind that the suspect responds differently to each toy, so I should vary it up if I'm getting stuck.
Mom::True, and that over time, their interest can change even on the same toy, so it's not always consistent.
"""

const TOO_AFRAID: String = """
Baby:Crying:WAAAAA!!! Dad's being a bully! Where's Mom? I want Mommy!!!
Mom::You went a bit far there, Dad, and now the suspect asked for their lawyer. We'll have to stop now.
Dad::Hmm, I'll have to keep an eye on the suspect's expressions and make sure I don't push them too far next time.
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
	baby.set_speaker_name("Oscar")


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
			baby.happiness_gate = 80.0
			baby.fearfullness_gate = 30.0
			baby.max_energy = 200.0
			baby.current_energy = 200.0
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
