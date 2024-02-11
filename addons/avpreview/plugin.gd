@tool
extends EditorPlugin
class_name AudioPreviewPlugin


var controls_2d: Control = null
var controls_3d: Control = null
var current_node: WeakRef = weakref(null)


func create_controls() -> Control:
	var preview := Button.new()
	preview.flat = true
	preview.text = "Preview"
	preview.connect("pressed", Callable(self, "preview"))
	
	var ret := HBoxContainer.new()
	ret.add_child(preview)
	ret.visible = false
	return ret


func preview() -> void:
	var node = current_node.get_ref()
	node.play()


func _enter_tree() -> void:
	controls_2d = create_controls()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, controls_2d)
	controls_3d = create_controls()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, controls_3d)


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, controls_2d)
	controls_2d.queue_free()
	controls_2d = null
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, controls_3d)
	controls_3d.queue_free()
	controls_3d = null


func _handles(object: Object) -> bool:
	return object is AudioStreamPlayer or object is VideoStreamPlayer


func _make_visible(visible: bool):
	controls_2d.visible = visible
	controls_3d.visible = visible


func _edit(object: Object) -> void:
	current_node = weakref(object)
