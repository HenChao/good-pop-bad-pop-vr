class_name ScriptManager
extends Node3D

signal scene_complete

@export_group("Player Controllers")
@export var left_controller: XRController3D
@export var right_controller: XRController3D

var _dad_speech_bubble: SpeechBubble
var _mom_puter: ComputerScreen
var _baby: Baby
var _last_active_speaker: Dialogue.Speakers


func set_actors(mom: ComputerScreen, dad: SpeechBubble, baby: Baby) -> void:
	_mom_puter = mom
	_dad_speech_bubble = dad
	_baby = baby


func start_scene(scene_text: String) -> Signal:
	_mom_puter.set_state(ComputerScreen.STATES.SILENT)
	_dad_speech_bubble.visible = false
	_baby.set_state(Baby.STATES.SILENT)

	var parsed_script: Array[Dialogue] = _parse_script(scene_text)
	for dialogue in parsed_script:
		await _display_speech_bubble(dialogue)
	_silence_all_actors()
	call_deferred("emit_signal", scene_complete)
	return scene_complete


## All text for a given string, passed in as one long string.
## Each line should be separated by new lines.
## Line will come in the following format:
## Speaker:Expression:Speech line
## Expressions are optional. Otherwise the speaker will default to a NEUTRAL expression.
func _parse_script(scene_text: String) -> Array[Dialogue]:
	var script: Array[Dialogue] = []
	var lines: PackedStringArray = scene_text.split("\n")
	
	for line in lines:
		if not line: # Skip an empty line.
			continue
		var dialogue = Dialogue.new()
		var split_line: PackedStringArray = line.split(":")
		match split_line[0]:
			"Mom":
				dialogue.speaker = Dialogue.Speakers.MOM
			"Dad":
				dialogue.speaker = Dialogue.Speakers.DAD
			"Baby":
				dialogue.speaker = Dialogue.Speakers.BABY
		if split_line[1]:
			dialogue.expression = split_line[1]
		dialogue.line = split_line[2]
		script.append(dialogue)
	return script


func _display_speech_bubble(dialogue: Dialogue) -> Signal:
	# Determine who is talking, and set the appropriate visibility to their speech bubble.
	if _last_active_speaker != dialogue.speaker:
		# New speaker for this line, so hide last speaker's speech bubble
		var prev_speech_bubble: SpeechBubble = _silence_speaker(_last_active_speaker)
		_unbind_controller_inputs_to_speech_bubble(prev_speech_bubble)
	var active_speech_bubble: SpeechBubble = _set_active_dialogue(dialogue)
	active_speech_bubble.set_text(dialogue.line)
	_bind_controller_inputs_to_speech_bubble(active_speech_bubble)
	_last_active_speaker = dialogue.speaker
	return active_speech_bubble.confirmed_input


func _silence_speaker(speaker: Dialogue.Speakers) -> SpeechBubble:
	match speaker:
		Dialogue.Speakers.MOM:
			_mom_puter.set_state(ComputerScreen.STATES.SILENT)
			return _mom_puter.get_speech_bubble()
		Dialogue.Speakers.DAD:
			_dad_speech_bubble.visible = false
			return _dad_speech_bubble
		Dialogue.Speakers.BABY:
			_baby.set_state(Baby.STATES.SILENT)
			return _baby.get_speech_bubble()
	return null


func _set_active_dialogue(dialogue: Dialogue) -> SpeechBubble:
	match dialogue.speaker:
		Dialogue.Speakers.MOM:
			_mom_puter.set_state(ComputerScreen.STATES.TALKING)
			_mom_puter.set_expression(dialogue.expression)
			return _mom_puter.get_speech_bubble()
		Dialogue.Speakers.DAD:
			_dad_speech_bubble.visible = true
			return _dad_speech_bubble
		Dialogue.Speakers.BABY:
			_baby.set_state(Baby.STATES.TALKING)
			_baby.set_expression(dialogue.expression)
			return _baby.get_speech_bubble()
	return null


func _bind_controller_inputs_to_speech_bubble(speech_bubble: SpeechBubble) -> void:
	if not speech_bubble:
		return
	if not left_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		left_controller.button_pressed.connect(speech_bubble.on_controller_input)
	if not right_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		right_controller.button_pressed.connect(speech_bubble.on_controller_input)


func _unbind_controller_inputs_to_speech_bubble(speech_bubble: SpeechBubble) -> void:
	if not speech_bubble:
		return
	if left_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		left_controller.button_pressed.disconnect(speech_bubble.on_controller_input)
	if right_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		right_controller.button_pressed.disconnect(speech_bubble.on_controller_input)


func _silence_all_actors() -> void:
	_mom_puter.set_state(ComputerScreen.STATES.SILENT)
	_dad_speech_bubble.visible = false
	_baby.set_state(Baby.STATES.SILENT)
