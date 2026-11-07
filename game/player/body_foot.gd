class_name BodyFoot
extends BodyPart

var side: float
var sole_height: float
var world_center: Vector2
var shown_center: Vector2
var ground_normal: Vector2 = Vector2.UP
var target_normal: Vector2 = Vector2.UP
var is_planted: bool = false
var step_from: Vector2
var step_progress: float = -1.0


func _init(part_node: Capsule, foot_side: float) -> void:
	super(part_node)
	side = foot_side
	sole_height = part_node.size.y / 2.0
	world_center = node.global_position
	shown_center = world_center


func is_stepping() -> bool:
	return step_progress >= 0.0


func start_step() -> void:
	step_from = world_center
	step_progress = 0.0
