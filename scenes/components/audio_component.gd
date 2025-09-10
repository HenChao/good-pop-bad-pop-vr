class_name AudioComponent
extends Node3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D
@export var audio_stream: AudioStream


func _ready() -> void:
	audio_stream_player_3d.stream = audio_stream


func play_sound() -> void:
	if audio_stream_player_3d.playing:
		return
	audio_stream_player_3d.pitch_scale = randf_range(0.8, 1.2)  # Randomize pitch to avoid repetitive sounds.
	audio_stream_player_3d.play()
