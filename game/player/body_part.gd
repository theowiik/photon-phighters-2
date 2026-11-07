class_name BodyPart
extends RefCounted

var node: Node2D
var rest_rotation: float
var rest_center: Vector2
var spring: BodySpring
var roll: float = 0.0
var roll_velocity: float = 0.0


func _init(part_node: Node2D) -> void:
	node = part_node
	rest_rotation = node.rotation
	rest_center = node.position
	spring = BodySpring.new((node.get_parent() as Node2D).transform * rest_center)


func place(center: Vector2) -> void:
	node.position = center
	node.rotation = rest_rotation + roll


func spin(target: float, stiffness: float, damping: float, delta: float) -> void:
	roll_velocity += (stiffness * (target - roll) - damping * roll_velocity) * delta
	roll += roll_velocity * delta
