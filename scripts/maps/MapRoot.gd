class_name MapRoot extends Node3D


var MAP_MANAGER: Node3D = null
var PLAYER: CharacterBody3D = null


func on_spawn_player() -> void:
	pass


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
