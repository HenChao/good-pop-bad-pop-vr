@tool
class_name TutorialLevel
extends Node3D

var script_manager: ScriptManager

const intro_scene: String = """
Mom: Well Dad, it's shaping up to be another busy night tonight.
Dad: It always is around here. Sometimes I wonder if what we do makes any difference.
Mom: Of course it does. Never forget that we're the last line between order and chaos.
Dad: You're right of course. So what do you have for me first?
Mom: I know it's been a while, so we'll start off with a simple case.
Mom: I'll also walk you through the process step-by-step, just as a quick refresher.
Dad: Sounds good. I appreciate the help.
Mom: Don't mention it. I'm sure it'll be like riding a bike.
Mom: Our first case is a 211, straight B and E. It looks like someone stole a cookie from the cookie jar.
Mom: We'll bring the suspect into the room. Your job is to get a confession from them.
Mom: Start by talking with them, get their side of the story. Then press them for more information.
Mom: Note that you have only a small window of time to get a confession.
Mom: If you take too long, then they can get bored and sleepy, and we'll have to put them down for a nap.
Mom: The interrogation room can be a scary place, so try and make them feel comfortable.
Mom: We'll have some toys available on the table for you to use to soothe them.
Dad: Sounds good, I think I'm ready to start.
Mom: Good. We'll bring in the suspect now.
"""

const first_round: String = """
Dad: Well well well, I had a feeling I'd see you in here again one of these days.
Baby: I know I got in trouble before, but I didn't do anything.
Dad: We'll see about that. What do you know about the cookie from the cookie jar?
Baby: Cookie? What's a cookie? Never heard of any cookies.
"""


func _enter_tree() -> void:
	if not script_manager:
		push_error("Script manager not set for Tutorial level!")
	await script_manager.start_scene(intro_scene)


func set_script_manager(sm: ScriptManager) -> void:
	script_manager = sm
