@tool
class_name Level1
extends Node3D

signal level_complete(level_time: float)
signal level_failed

# gdlint: disable=max-line-length
const INTRO_SCENE: String = """
Mom::Got another case for you Dad. This one's a real career criminal. 4 time-outs in the last 3 days.
Dad::Jeez. I'm getting too old for this stuff, Chief. Don't you know that I'm 18 years away from retirement.
Mom::Well keep your boat docked for now, you still have a job to do.
Dad::No choice, I suppose. What did this one do today?
Mom::Bad case of assault. Seems that he hit Mayor Grandmom during tummy time today.
Mom::The Governor isn't happy with this. He wants an apology from the suspect sooner rather than later.
Dad::Governor Granddad already heard about this? Like I need any more pressure tonight.
Mom::We're giving you a lot of leeway with this one, but results are expected. Good luck.
"""

const FIRST_ROUND: String = """
Dad::So, you think hitting helpless old ladies is fun, do you?
Baby::Ha! I was provoked! I'm pretty sure the Supreme Court declared tummy time a cruel and unusual punishment.
Dad::That excuse won't fly in the sandbox, and it won't work here either.
"""

const SECOND_ROUND: String = """
Baby:Smiling:I like you, Pop. It's always fun to see the clowns working at the circus.
Dad::If you enjoy the clowns, then wait until you see the lion tamer.
"""

const SECOND_ROUND_INTERLUDE: String = """
Baby:Smiling:I don't know what you're expecting here, Pop, I know you got rules to follow.
Dad::Playtime's over, buddy. The rules went out the window when you swung at the Mayor.
"""

const SECOND_ROUND_TURNABOUT: String = """
Baby:Annoyed:Alright, fun is fun, but this is starting to get old.
Dad::Then why don't you just give them your apology and get it over with?
"""

const END_INTERROGATION: String = """
Baby::Oh alright. I'll give them an apology tomorrow. Happy?
Dad::I'd be more happy if you just avoid hitting people in the future.
Baby::That's a big ask. Maybe if my allowance went up a few cents?
Dad::Sorry, department policy is to not negotiate with toddlers.
Mom::Good job, Dad. The apology will go a long way with the higher ups.
Dad::Thanks Chief, but I can't help but feel like we were only doing the biddings of the Mayor and Governor tonight.
Mom::Deal with it. In the toy box of life, we're just the left over scraps of Play-Doh at the bottle of the container.
"""

const OUT_OF_ENERGY: String = """
Baby:Annoyed:Well Pop, if that's all you've got, I think it's time for my nap.
Mom:Annoyed:The higher ups won't be happy about this one, Dad. We needed that apology.
Dad::Sorry Chief. Maybe switching up the toys more often might help next time.
"""

const TOO_AFRAID: String = """
Baby:Crying:Alright Pop, that's going too far now. Lawyer Mom, now.
Mom:Annoyed:I know he's a tough customer, Dad, but you really need to be careful about cross the line.
Dad::Hmm, I'll have to be cautious about this one. He has a higher threshold than most for being afraid.
Dad::But that also means it's easy to go too far. As the Bad Pop, I'll have to go slowly to avoid pushing him too far.
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
	baby.set_speaker_name("Harold")


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
			baby.happiness_gate = 75.0
			baby.fearfullness_gate = 15.0
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
