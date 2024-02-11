class_name InteractNode3D extends Area3D


signal interacted_with()


func _on_interacted_with() -> void:
	interacted_with.emit()
