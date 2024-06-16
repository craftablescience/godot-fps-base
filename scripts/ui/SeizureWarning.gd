extends Control


signal continue_to_menu()


func _on_contents_meta_clicked(meta: Variant) -> void:
	var data := str(meta)
	if data == "disable_flicker_and_continue":
		Globals.disable_flicker = true
	continue_to_menu.emit()
