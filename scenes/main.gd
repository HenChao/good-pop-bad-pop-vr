extends Node3D

@onready var game_objects: Node3D = %GameObjects
@onready var paused_menu: PausedMenu = %PausedMenu


func _ready() -> void:
	paused_menu.visible = false
	paused_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_player_menu_button_hit() -> void:
	if get_tree().paused:
		_unpause_game()
	else:
		_pause_game()


func _on_paused_menu_resume_game_button_pressed() -> void:
	_unpause_game()


func _pause_game() -> void:
	get_tree().paused = true
	paused_menu.visible = true
	game_objects.visible = false


func _unpause_game() -> void:
	paused_menu.visible = false
	game_objects.visible = true
	get_tree().paused = false
