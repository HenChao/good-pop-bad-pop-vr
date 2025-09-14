class_name AudioComponent
extends Node3D

@export var audio_stream: AudioStream

@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D


func _ready() -> void:
	audio_stream_player_3d.stream = audio_stream


func play_sound() -> void:
	if audio_stream_player_3d.playing:
		return
	# Randomize pitch to avoid repetitive sounds.
	# If Good Pop, play normal sound.
	# If Bad Pop, play at lower pitch.
	if Player.is_currently_good_pop:
		audio_stream_player_3d.pitch_scale = randf_range(0.8, 1.2)
	else:
		audio_stream_player_3d.pitch_scale = randf_range(0.4, 0.6)
	audio_stream_player_3d.play()


func stop_sound() -> void:
	if audio_stream_player_3d.playing:
		audio_stream_player_3d.stop()
