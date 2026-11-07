@tool
class_name MapPiece
extends StaticBody3D
## A solid block to build maps with. Resize it with [member size] instead of scaling the
## node, so the collision always matches the mesh.

enum Shape { BOX, RAMP, CYLINDER }

const MIN_SIZE: float = 0.1

## Ramps rise toward -X. Cylinders use X as the diameter and Y as the height.
@export var shape: Shape = Shape.BOX:
	set(value):
		shape = value
		_rebuild()

@export var size: Vector3 = Vector3(4.0, 1.0, 4.0):
	set(value):
		size = value.max(Vector3.ONE * MIN_SIZE)
		_rebuild()

@export var color: Color = Color("5b6478"):
	set(value):
		color = value
		_rebuild()

var _mesh_instance: MeshInstance3D = MeshInstance3D.new()
var _collision: CollisionShape3D = CollisionShape3D.new()


func _ready() -> void:
	add_child(_mesh_instance, false, INTERNAL_MODE_FRONT)
	add_child(_collision, false, INTERNAL_MODE_FRONT)
	_rebuild()


func _rebuild() -> void:
	if not is_node_ready():
		return

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	_mesh_instance.mesh = _make_mesh()
	_mesh_instance.material_override = material
	_collision.shape = _make_shape()


func _make_mesh() -> Mesh:
	match shape:
		Shape.RAMP:
			var prism := PrismMesh.new()
			prism.left_to_right = 0.0
			prism.size = size
			return prism
		Shape.CYLINDER:
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = size.x / 2.0
			cylinder.bottom_radius = size.x / 2.0
			cylinder.height = size.y
			return cylinder
	var box := BoxMesh.new()
	box.size = size
	return box


func _make_shape() -> Shape3D:
	match shape:
		Shape.RAMP:
			var ramp := ConvexPolygonShape3D.new()
			var half := size / 2.0
			ramp.points = [
				Vector3(-half.x, -half.y, -half.z),
				Vector3(-half.x, -half.y, half.z),
				Vector3(half.x, -half.y, -half.z),
				Vector3(half.x, -half.y, half.z),
				Vector3(-half.x, half.y, -half.z),
				Vector3(-half.x, half.y, half.z),
			]
			return ramp
		Shape.CYLINDER:
			var cylinder := CylinderShape3D.new()
			cylinder.radius = size.x / 2.0
			cylinder.height = size.y
			return cylinder
	var box := BoxShape3D.new()
	box.size = size
	return box
