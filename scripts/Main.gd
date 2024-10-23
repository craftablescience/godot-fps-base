extends Control


# state
var game_has_started := false
var game_has_ended := false
var pause_is_allowed := true


func pause() -> void:
	if not pause_is_allowed:
		return
	
	get_tree().paused = true
	$Crosshair.hide()
	$MapManager.get_player().hide_ui()
	$Menu.show()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume() -> void:
	if game_has_ended:
		return
	
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
	if Globals.GLOBAL_OPTS["show_debug_stats"]:
		$Debug.show()
	elif not Globals.DEBUG:
		$Debug.queue_free()
	
	if Globals.GLOBAL_OPTS["start_windowed"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	$MapManager.load_map("res://scenes/maps/%s.tscn" % Globals.GLOBAL_OPTS["start_map"], Vector3(-1,-1,1))
	$MapManager.show_preview_camera(Vector3(-1,-1,1))
	
	if Globals.GLOBAL_OPTS["use_promo_menu"]:
		$Menu.queue_free()
		$SeizureWarning.queue_free()
		$PromoMenu.show()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(640 * 2.5, 320 * 2.5))
		pause()
		return
	else:
		$PromoMenu.queue_free()
	
	if Globals.GLOBAL_OPTS["skip_seizure_warning"]:
		$SeizureWarning.queue_free()
		$Menu.notify_menu_shown()
	
	pause()


func _process(_delta: float) -> void:
	if Globals.DEBUG and Input.is_action_just_pressed("dbg_toggle"):
		$Debug.visible = not $Debug.visible


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and game_has_started:
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_map_manager_game_ended_and_we_should_show_the_credits_now() -> void:
	$Menu.notify_game_ended(false)
	$MapManager.show_preview_camera(Vector3(-1,-1,1))
	game_has_ended = true
	pause_is_allowed = true
	pause()


func _on_map_manager_game_ended_but_we_might_play_it_again() -> void:
	$Menu.notify_game_ended(true)
	$MapManager.show_preview_camera(Vector3(-1,-1,1))
	game_has_started = false
	game_has_ended = false
	pause_is_allowed = true
	pause()


func _on_map_manager_we_are_in_a_no_pause_cutscene_now() -> void:
	resume() # just to make sure
	pause_is_allowed = false


func _on_map_manager_we_are_not_in_a_no_pause_cutscene_anymore() -> void:
	pause_is_allowed = true


func _on_seizure_warning_continue_to_menu() -> void:
	$Menu.modulate = Color(1,1,1,0)
	var tween := get_tree().create_tween().bind_node(self)
	tween.tween_property($SeizureWarning, "modulate", Color(1,1,1,0), 0.5)
	tween.tween_callback(func() -> void:
		$SeizureWarning.queue_free()
		$Menu.notify_menu_shown())
	tween.tween_property($Menu, "modulate", Color(1,1,1,1), 0.75)
	tween.play()
