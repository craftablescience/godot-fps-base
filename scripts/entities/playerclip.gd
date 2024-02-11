extends Node3D


var loaded_children := false


func _process(_delta: float) -> void:
	if loaded_children:
		return
	
	for child in get_children():
		if child is MeshInstance3D:
			loaded_children = true
			child.create_convex_collision(true, true)
			child.visible = false
