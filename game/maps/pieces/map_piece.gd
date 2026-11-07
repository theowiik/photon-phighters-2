@tool
class_name MapPiece
extends StaticBody2D
## A solid block to build maps with. Resize it with [member size] instead of scaling the
## node, so the collision always matches the drawing.

enum Shape { BOX, RAMP, CIRCLE }

const MIN_SIZE: float = 4.0
const RIM_WIDTH: float = 2.0
const RIM_LIGHTEN: float = 0.3

## Ramps rise toward -X; mirror one with a scale of (-1, 1). Circles use X as the diameter.
@export var shape: Shape = Shape.BOX:
	set(value):
		shape = value
		_rebuild()

@export var size: Vector2 = Vector2(128.0, 32.0):
	set(value):
		size = value.max(Vector2.ONE * MIN_SIZE)
		_rebuild()

@export var color: Color = Color("232a45"):
	set(value):
		color = value
		_rebuild()

var _collision: CollisionShape2D = CollisionShape2D.new()


func _ready() -> void:
	add_child(_collision, false, INTERNAL_MODE_FRONT)
	_rebuild()


func _rebuild() -> void:
	if not is_node_ready():
		return

	_collision.shape = _make_shape()
	queue_redraw()


func _draw() -> void:
	var rim := color.lightened(RIM_LIGHTEN)
	if shape == Shape.CIRCLE:
		draw_circle(Vector2.ZERO, size.x / 2.0, color)
		draw_circle(Vector2.ZERO, size.x / 2.0 - RIM_WIDTH / 2.0, rim, false, RIM_WIDTH)
		return

	var points := _polygon()
	draw_colored_polygon(points, color)
	points.append(points[0])
	draw_polyline(points, rim, RIM_WIDTH)


func _make_shape() -> Shape2D:
	if shape == Shape.CIRCLE:
		var circle := CircleShape2D.new()
		circle.radius = size.x / 2.0
		return circle

	var polygon := ConvexPolygonShape2D.new()
	polygon.set_point_cloud(_polygon())
	return polygon


func _polygon() -> PackedVector2Array:
	var half := size / 2.0
	if shape == Shape.RAMP:
		return PackedVector2Array([-half, Vector2(half.x, half.y), Vector2(-half.x, half.y)])
	return PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
