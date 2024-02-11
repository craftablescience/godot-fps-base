@tool
class_name AxisHelper3D extends Node3D


const AXIS_HELPER_3D_SCENE := preload("res://scenes/nodes/AxisHelper3D.tscn")


func _ready() -> void:
	if Engine.is_editor_hint():
		add_child(AXIS_HELPER_3D_SCENE.instantiate())
