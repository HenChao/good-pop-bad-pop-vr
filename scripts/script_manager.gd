class_name ScriptManager
extends Node3D

signal scene_complete

@export_group("Player Controllers")
@export var left_controller: XRController3D
@export var right_controller: XRController3D

var _dad_speech_bubble: SpeechBubble
var _mom_speech_bubble: SpeechBubble
var _baby_speech_bubble: SpeechBubble

var _last_active_speaker: Dialogue.Speakers


func set_speech_bubbles(mom: SpeechBubble, dad: SpeechBubble, baby: SpeechBubble) -> void:
	_mom_speech_bubble = mom
	_dad_speech_bubble = dad
	_baby_speech_bubble = baby


func start_scene(scene_text: String) -> Signal:
	_mom_speech_bubble.visisble = false
	_dad_speech_bubble.visible = false
	_baby_speech_bubble.visible = false

	var parsed_script: Array[Dialogue] = _parse_script(scene_text)
	for dialogue in parsed_script:
		await _display_speech_bubble(dialogue)
	call_deferred("emit_signal", scene_complete)
	return scene_complete


func _parse_script(scene_text: String) -> Array[Dialogue]:
	var script: Array[Dialogue] = []
	var lines: Array[String] = scene_text.split("\n")
	
	for line in lines:
		var dialogue = Dialogue.new()
		line.split(":")
		match line[0]:
			"Mom":
				dialogue.speaker = Dialogue.Speakers.MOM
			"Dad":
				dialogue.speaker = Dialogue.Speakers.DAD
			"Baby":
				dialogue.speaker = Dialogue.Speakers.BABY
		dialogue.line = line[1]
		script.append(dialogue)
	return script


func _display_speech_bubble(dialogue: Dialogue) -> Signal:
	# Determine who is talking, and set the appropriate visibility to their speech bubble.
	if not _last_active_speaker:
		_last_active_speaker = dialogue.speaker
	elif _last_active_speaker != dialogue.speaker:
		# New speaker for this line, so hide last speaker's speech bubble
		var prev_speech_bubble: SpeechBubble = _get_speech_bubble(_last_active_speaker)
		prev_speech_bubble.visible = false
		_unbind_controller_inputs_to_speech_bubble(prev_speech_bubble)
	var active_speech_bubble: SpeechBubble = _get_speech_bubble(dialogue.speaker)
	active_speech_bubble.visible = true
	active_speech_bubble.set_text(dialogue.line)
	_bind_controller_inputs_to_speech_bubble(active_speech_bubble)
	return active_speech_bubble.confirmed_input


func _get_speech_bubble(speaker: Dialogue.Speakers) -> SpeechBubble:
	match speaker:
		Dialogue.Speakers.MOM:
			return _mom_speech_bubble
		Dialogue.Speakers.DAD:
			return _dad_speech_bubble
		Dialogue.Speakers.BABY:
			return _baby_speech_bubble
	return null


func _bind_controller_inputs_to_speech_bubble(speech_bubble: SpeechBubble) -> void:
	if not left_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		left_controller.button_pressed.connect(speech_bubble.on_controller_input)
	if not right_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		right_controller.button_pressed.connect(speech_bubble.on_controller_input)


func _unbind_controller_inputs_to_speech_bubble(speech_bubble: SpeechBubble) -> void:
	if left_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		left_controller.button_pressed.disconnect(speech_bubble.on_controller_input)
	if right_controller.button_pressed.is_connected(speech_bubble.on_controller_input):
		right_controller.button_pressed.disconnect(speech_bubble.on_controller_input)
