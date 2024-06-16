# https://github.com/godotengine/godot/issues/66247
# How the fuck is this still an issue in 4.2.2 when it was discovered before 4.0 released
class_name SubViewportFixer3D extends Node3D


@export var viewport: SubViewport
@export var mesh: MeshInstance3D
@export var use_emissive: bool = true
@export var transparency: BaseMaterial3D.Transparency = BaseMaterial3D.Transparency.TRANSPARENCY_DISABLED


func _ready() -> void:
	RenderingServer.frame_post_draw.connect(on_draw.bind())


func on_draw() -> void:
	var tex = viewport.get_texture()
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = transparency
	mat.albedo_texture = tex
	if use_emissive:
		mat.emission_enabled = true
		mat.emission_texture = tex
	mesh.set_surface_override_material(0, mat)
	RenderingServer.frame_post_draw.disconnect(on_draw.bind())
