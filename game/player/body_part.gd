class_name BodyPart
extends RefCounted

var node: Node3D
var rest_basis: Basis
var pivot: Vector3
var rest_center: Vector3
var spring: BodySpring
var roll: float = 0.0
var roll_velocity: float = 0.0


func _init(part_node: Node3D) -> void:
	node = part_node
	rest_basis = node.basis
	pivot = _mesh_center()
	rest_center = node.transform * pivot
	spring = BodySpring.new(node.get_parent_node_3d().transform * rest_center)


func place(center: Vector3) -> void:
	var turned := Basis(Vector3.BACK, roll) * rest_basis
	node.transform = Transform3D(turned, center - turned * pivot)


func spin(target: float, stiffness: float, damping: float, delta: float) -> void:
	roll_velocity += (stiffness * (target - roll) - damping * roll_velocity) * delta
	roll += roll_velocity * delta


func _mesh_center() -> Vector3:
	var bounds := AABB()
	var has_bounds := false
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_bounds: AABB = child.transform * (child as MeshInstance3D).get_aabb()
			bounds = bounds.merge(mesh_bounds) if has_bounds else mesh_bounds
			has_bounds = true
	return bounds.get_center()
