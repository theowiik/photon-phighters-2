class_name Laser
extends Node3D

var mesh: ImmediateMesh
var instance: MeshInstance3D
var material: StandardMaterial3D
var color: Color = Color.RED

@onready var ray: RayCast3D = $RayCast3D


func _ready() -> void:
	mesh = ImmediateMesh.new()
	instance = MeshInstance3D.new()
	instance.mesh = mesh

	material = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	instance.material_override = material

	add_child(instance)


func set_color(new_color: Color) -> void:
	color = new_color
	if material:
		material.albedo_color = color


func _physics_process(_delta: float) -> void:
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(Vector3.ZERO)

	if ray.is_colliding():
		mesh.surface_add_vertex(to_local(ray.get_collision_point()))
	else:
		mesh.surface_add_vertex(ray.target_position)

	mesh.surface_end()
