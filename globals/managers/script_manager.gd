class_name ScriptManager
extends Node3D

signal scene_complete

## References to controllers to in order to bind inputs to speech bubbles to progress text.
@export_group("Player Controllers")
@export var left_controller: XRController3D
@export var right_controller: XRController3D

@export_group("Audio Resources")
@export var audio_player: AudioStreamPlayer
@export var dad_sound: AudioStreamWAV
@export var mom_sound: AudioStreamWAV
@export var baby_sound: AudioStreamWAV

# Internal references to entities and speech bubbles to push lines and control display.
var _dad_speech_bubble: SpeechBubble
var _mom_puter: ComputerScreen
var _baby: Baby
var _last_active_speaker: Dialogue.Speakers


func set_actors(mom: ComputerScreen, dad: SpeechBubble, baby: Baby) -> void:
	_mom_puter = mom
	_dad_speech_bubble = dad
	_baby = baby


## Begin a scene. Input is one long string, which is then parsed and displayed.
func start_scene(scene_text: String) -> Signal:
	# Always start a scene with no one speaking
	_silence_all_actors()

	var parsed_script: Array[Dialogue] = _parse_script(scene_text)
	for dialogue in parsed_script:
		await _display_speech_bubble(dialogue)
		if audio_player.playing:
			audio_player.stop()
	
	# Always end with no one speaking
	_silence_all_actors()
	
	scene_complete.emit()
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
		if not line:  # Skip a empty lines.
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
			match split_line[1]:
				"Crying":
					dialogue.expression = Dialogue.Expressions.CRYING
				"Scared":
					dialogue.expression = Dialogue.Expressions.SCARED
				"Annoyed":
					dialogue.expression = Dialogue.Expressions.ANNOYED
				"Neutral":
					dialogue.expression = Dialogue.Expressions.NEUTRAL
				"Surprised":
					dialogue.expression = Dialogue.Expressions.SURPRISED
				"Smiling":
					dialogue.expression = Dialogue.Expressions.SMILING
				"Joyful":
					dialogue.expression = Dialogue.Expressions.JOYFUL
		dialogue.line = split_line[2]
		script.append(dialogue)
	return script


## Show the appropriate speech bubble for a given line of dialogue. Hides speech bubbles for anyone
## who isn't actively speaking.
func _display_speech_bubble(dialogue: Dialogue) -> Signal:
	# Determine who is talking, and set the appropriate visibility to their speech bubble.
	if _last_active_speaker != dialogue.speaker:
		# New speaker for this line, so hide last speaker's speech bubble
		_silence_speaker_and_unbind_input(_last_active_speaker)
	var active_speech_bubble: SpeechBubble = _set_active_dialogue(dialogue)
	active_speech_bubble.set_text(dialogue.line)
	_bind_controller_inputs_to_speech_bubble(active_speech_bubble)
	_play_audio(dialogue.speaker)
	_last_active_speaker = dialogue.speaker
	return active_speech_bubble.confirmed_input


## Hide the speech bubble for the given speaker. Unbind player input from SpeechBubble as well.
func _silence_speaker_and_unbind_input(speaker: Dialogue.Speakers) -> void:
	var prev_speech_bubble: SpeechBubble
	match speaker:
		Dialogue.Speakers.MOM:
			_mom_puter.set_state(ComputerScreen.States.SILENT)
			prev_speech_bubble = _mom_puter.get_speech_bubble()
		Dialogue.Speakers.DAD:
			_dad_speech_bubble.visible = false
			prev_speech_bubble = _dad_speech_bubble
		Dialogue.Speakers.BABY:
			_baby.set_state(Baby.States.SILENT)
			prev_speech_bubble = _baby.get_speech_bubble()
	_unbind_controller_inputs_to_speech_bubble(prev_speech_bubble)


## Play the audio stream for the given speaker. Modify pitch scale to distinguish between speakers.
func _play_audio(speaker: Dialogue.Speakers) -> void:
	var stream: AudioStreamWAV
	# Randomize pitch scale to avoid audio fatigue.
	match speaker:
		Dialogue.Speakers.MOM:
			stream = mom_sound
			audio_player.pitch_scale = randf_range(0.9, 1.1)
		Dialogue.Speakers.DAD:
			stream = dad_sound
			audio_player.pitch_scale = randf_range(0.5, 0.6)
		Dialogue.Speakers.BABY:
			stream = baby_sound
			audio_player.pitch_scale = randf_range(1.9, 2.0)
	audio_player.stream = stream
	audio_player.play()


## Show the speech bubble for the given speaker. Returns the SpeechBubble object so that script
## progression is tied to when user input signal is emitted.
func _set_active_dialogue(dialogue: Dialogue) -> SpeechBubble:
	match dialogue.speaker:
		Dialogue.Speakers.MOM:
			_mom_puter.set_state(ComputerScreen.States.TALKING)
			_mom_puter.set_expression(dialogue.expression)
			return _mom_puter.get_speech_bubble()
		Dialogue.Speakers.DAD:
			_dad_speech_bubble.visible = true
			return _dad_speech_bubble
		Dialogue.Speakers.BABY:
			_baby.set_state(Baby.States.TALKING)
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
	_mom_puter.set_state(ComputerScreen.States.SILENT)
	_dad_speech_bubble.visible = false
	_baby.set_state(Baby.States.SILENT)
	if audio_player.playing:
		audio_player.stop()
