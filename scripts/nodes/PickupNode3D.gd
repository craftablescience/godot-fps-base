class_name PickupNode3D extends RigidBody3D


signal picked_up()
signal put_down()


func _on_picked_up() -> void:
	picked_up.emit()


func _on_put_down() -> void:
	put_down.emit()
