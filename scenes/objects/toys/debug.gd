extends Label3D


func _physics_process(_delta: float) -> void:
	text = str(get_parent().global_rotation_degrees.z)
