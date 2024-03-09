extends Control


signal resume()


func fixup_all_buttons(n: Node) -> void:
	"""
	Loop over all buttons and add signals to:
	- Display the hover text to the left and play hover sound when hovered
	- Play a click sound
	"""
	for child in n.get_children():
		if child.get_child_count() > 0:
			fixup_all_buttons(child)
		elif child is BaseButton:
			# Selection label stuff
			var on_entered = func() -> void:
				# 4 is a magic number that works
				# Don't question it
				$SelectionLabel.set_global_position(Vector2(child.global_position.x, child.global_position.y + 4))
				$SelectionLabel.set_global_position($SelectionLabel.global_position - Vector2($SelectionLabel.size.x, 0))
				$HoverSound.play()
			var on_exited = func() -> void:
				$SelectionLabel.set_global_position(Vector2(0, -$SelectionLabel.size.y))
			child.connect("mouse_entered", on_entered)
			child.connect("mouse_exited", on_exited)
			# Hack to clear the selection when changing between menus
			if child is Button:
				child.connect("pressed", on_exited)
			
			# Play a sound on click
			var on_pressed = func() -> void:
				$ClickSound.play()
			child.connect("pressed", on_pressed)


func reset() -> void:
	$TabContainer.current_tab = 0


func notify_game_started() -> void:
	$TabContainer/MainOptions/Play.hide()
	$TabContainer/MainOptions/Resume.show()


func notify_game_ended() -> void:
	# We don't want them to play the game again, only show Credits and Leave
	#$TabContainer/MainOptions/Play.show()
	$TabContainer/MainOptions/Play.hide()
	$TabContainer/MainOptions/Resume.hide()
	
	$TabContainer/MainOptions/Settings.hide()


func _ready() -> void:
	$Title.text = ProjectSettings.get_setting("application/config/name")
	reset()
	fixup_all_buttons(self)


func _on_play_pressed() -> void:
	resume.emit()


func _on_menu_button_pressed(index: int) -> void:
	$TabContainer.current_tab = index


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_invert_y_toggled(button_pressed: bool) -> void:
	Globals.invert_y = button_pressed


func _on_fov_value_changed(value: float) -> void:
	Globals.field_of_view = value


func _on_credits_meta_clicked(meta: Variant) -> void:
	if OS.get_name() != "HTML5":
		OS.shell_open(str(meta))
	else:
		JavaScriptBridge.eval("window.open('%s');" % str(meta), true)


func _on_quit_pressed() -> void:
	get_tree().quit()
