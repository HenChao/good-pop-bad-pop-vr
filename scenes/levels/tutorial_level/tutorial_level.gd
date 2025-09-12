@tool
class_name TutorialLevel
extends Node3D

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
Mom::Play the role of the bad pop and be more aggressive with your questioning.
Mom::Just remember, don't take it too far, or else they'll call for their lawyer.
Mom::Once you think you've gotten them sufficiently scared, then play peek-a-boo again to switch back to good pop.
Mom::You should then be able to play with them and get them back to a good spot.
Dad::Alright Chief, I'll give it a shot.
"""
# gdlint: enable=max-line-length

var script_manager: ScriptManager

@onready var dad_speech_bubble: SpeechBubble = $InterrogationTable/SpeechBubble
@onready var mom_puter: ComputerScreen = %ComputerScreen
@onready var baby: Baby = %Baby
@onready var interrogation_table: InterrogationTable = %InterrogationTable
@onready var overhead_light: XRToolsPickable = %OverheadLight


func _ready() -> void:
	baby.visible = false


func start_level() -> void:
	# Play the intro dialogue.
	await script_manager.start_scene(INTRO_SCENE)
	# Bring in the suspect.
	baby.visible = true
	await script_manager.start_scene(FIRST_ROUND)
	baby.start_interrogation()
	interrogation_table.initialize_toys()
	await baby.sufficiently_entertained
	await script_manager.start_scene(SECOND_ROUND)
	# Set stats for the second round
	baby.current_mood = 50.0
	baby.happiness_gate = 80.0
	baby.fearfullness_gate = 30.0
	baby.max_energy = 200.0
	baby.current_energy = 200.0
	baby.start_interrogation()
	await baby.happiness_gate_reached
	baby.stop_interrogation()
	await script_manager.start_scene(SECOND_ROUND_INTERLUDE)
	baby.start_interrogation()


func set_script_manager(sm: ScriptManager) -> void:
	script_manager = sm
	sm.set_actors(mom_puter, dad_speech_bubble, baby)


func set_player_reference(player: Player) -> void:
	player.player_persona_changed.connect(_on_pop_switch)


func _on_pop_switch() -> void:
	overhead_light.update_lighting()
