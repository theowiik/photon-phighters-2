class_name BodyFoot
extends BodyPart

var side: float
var sole_height: float
var world_center: Vector3
var shown_center: Vector3
var ground_normal: Vector3 = Vector3.UP
var target_normal: Vector3 = Vector3.UP
var is_planted: bool = false
var step_from: Vector3
var step_progress: float = -1.0


func _init(part_node: Node3D, foot_side: float) -> void:
	super(part_node)
	side = foot_side
	sole_height = rest_center.y - node.position.y
	world_center = node.global_transform * pivot
	shown_center = world_center


func is_stepping() -> bool:
	return step_progress >= 0.0


func start_step() -> void:
	step_from = world_center
	step_progress = 0.0
