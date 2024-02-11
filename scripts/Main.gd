extends Control


# state
var game_has_started := false


func pause() -> void:
	get_tree().paused = true
	$Crosshair.hide()
	$MapManager.get_player().hide_ui()
	$Menu.show()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume() -> void:
	var fadeout := 1.0
	
	if not game_has_started:
		$MapManager.spawn_player(Vector3(fadeout, 1, 1))
		$Menu.notify_game_started()
	
	get_tree().paused = false
	$Menu.hide()
	
	if not game_has_started:
		await get_tree().create_timer(fadeout).timeout
		game_has_started = true
	
	$Crosshair.show()
	$MapManager.get_player().show_ui()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	if Globals.DEBUG_OPTS["start_windowed"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(640, 480))
		
		var screen_size = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
		var window_size = DisplayServer.window_get_size_with_decorations()
		DisplayServer.window_set_position(screen_size / 2 - window_size / 2)
	
	if not Globals.DEBUG_OPTS["force_map"].is_empty():
		$MapManager.load_map("res://scenes/maps/%s.tscn" % Globals.DEBUG_OPTS["force_map"], Vector3(-1, -1, 1))
	else:
		$MapManager.load_map("res://scenes/maps/Map.tscn", Vector3(-1, -1, 1))
	
	$MapManager.show_preview_camera(Vector3(-1, -1, 1))
	
	if Globals.DEBUG_OPTS["use_promo_menu"]:
		$Menu.queue_free()
		$PromoMenu.show()
		DisplayServer.window_set_size(Vector2i(640, 320))
	else:
		$PromoMenu.queue_free()
	
	pause()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and game_has_started:
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_map_manager_game_ended():
	game_has_started = false
	
	# todo: load ending map
	$MapManager.show_preview_camera()
	$Menu.notify_game_ended()
	
	pause()
