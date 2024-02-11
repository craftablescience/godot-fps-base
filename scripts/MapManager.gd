extends Node3D


signal game_ended()


var map_instance: Node3D = null


func _process(_delta: float) -> void:
	# todo: use signals
	$Player.get_node("RotationHelper/Camera").fov = Globals.field_of_view
	if map_instance:
		map_instance.get_node("PreviewCamera").fov = Globals.field_of_view


func load_map(map: String, fade: Vector3 = Vector3()) -> void:
	var swap_map := func() -> void:
		if map_instance:
			remove_child(map_instance)
			map_instance.queue_free()
		
		map_instance = load(map).instantiate()
		map_instance.MAP_MANAGER = self
		map_instance.PLAYER = $Player
		map_instance.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(map_instance)
		
		$Player.global_position = map_instance.get_node("PlayerSpawn").global_position
		$Player.rotation = map_instance.get_node("PlayerSpawn").rotation
		
		if fade.y <= 0.0 and fade.z <= 0.0:
			$Fade.color = Color(0,0,0,0)
		else:
			var tween := get_tree().create_tween().bind_node(self)
			if fade.y > 0.0:
				tween.tween_property($Fade, "color", Color(0,0,0,1), fade.y)
			if fade.z > 0.0:
				tween.tween_property($Fade, "color", Color(0,0,0,0), fade.z)
			tween.play()
	
	if fade.x <= 0.0:
		$Fade.color = Color(0,0,0,1)
		swap_map.call()
	else:
		var tween := get_tree().create_tween().bind_node(self)
		tween.tween_property($Fade, "color", Color(0,0,0,1), fade.x)
		tween.tween_callback(swap_map)
		tween.play()


func show_preview_camera(fade: Vector3 = Vector3()) -> void:
	var swap_camera := func() -> void:
		if map_instance:
			map_instance.get_node("PreviewCamera").current = true
			
			if fade.y <= 0.0 and fade.z <= 0.0:
				$Fade.color = Color(0,0,0,0)
			else:
				var tween := get_tree().create_tween().bind_node(self)
				if fade.y > 0.0:
					tween.tween_property($Fade, "color", Color(0,0,0,1), fade.y)
				if fade.z > 0.0:
					tween.tween_property($Fade, "color", Color(0,0,0,0), fade.z)
				tween.play()
		else:
			printerr("Attempted to show preview camera, but map has not been loaded!")
	
	if fade.x <= 0.0:
		$Fade.color = Color(0,0,0,1)
		swap_camera.call()
		return
	
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property($Fade, "color", Color(0,0,0,1), fade.x)
	tween.tween_callback(swap_camera)
	tween.play()


func spawn_player(fade: Vector3 = Vector3()) -> void:
	var swap_camera := func() -> void:
		if map_instance:
			$Player.reset()
			map_instance.get_node("PreviewCamera").current = false
			
			if fade.y <= 0.0 and fade.z <= 0.0:
				$Fade.color = Color(0,0,0,0)
			else:
				var tween := get_tree().create_tween().bind_node(self)
				if fade.y > 0.0:
					tween.tween_property($Fade, "color", Color(0,0,0,1), fade.y)
				if fade.z > 0.0:
					tween.tween_property($Fade, "color", Color(0,0,0,0), fade.z)
				tween.play()
		else:
			printerr("Attempted to spawn player, but map has not been loaded!")
	
	if fade.x <= 0.0:
		$Fade.color = Color(0,0,0,1)
		swap_camera.call()
		return
	
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property($Fade, "color", Color(0,0,0,1), fade.x)
	tween.tween_callback(swap_camera)
	tween.play()


func get_player() -> CharacterBody3D:
	return $Player
