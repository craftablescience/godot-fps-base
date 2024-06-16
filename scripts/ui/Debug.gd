extends Control


func _process(_delta: float) -> void:
	$FPS.text = "FPS: %d" % Engine.get_frames_per_second()
