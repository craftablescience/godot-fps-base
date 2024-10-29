extends Control


signal continue_to_menu()


func _on_contents_meta_clicked(_meta: Variant) -> void:
	continue_to_menu.emit()
