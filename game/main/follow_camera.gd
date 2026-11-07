class_name FollowCamera
extends Camera2D

const MIN_ZOOM: float = 0.6
const MAX_ZOOM: float = 1.8
const FRAMING_MARGIN: float = 448.0
const FRAMING_OFFSET: Vector2 = Vector2(0.0, -32.0)
const DEV_ZOOM_STEP: float = 1.25

@export var smoothing_speed: float = 4.0
var follow: Array[Player] = []
var zoom_offset: float = 1.0
var _framed_position: Vector2
var _framed_zoom: float


func _ready() -> void:
	follow = Groups.get_all_players()
	var bounds := _player_bounds()
	_framed_position = bounds.get_center() + FRAMING_OFFSET
	_framed_zoom = _zoom_to_fit(bounds)
	global_position = _framed_position
	zoom = Vector2.ONE * _framed_zoom


func _physics_process(delta: float) -> void:
	var weight := 1.0 - exp(-smoothing_speed * delta)
	var bounds := _player_bounds()
	_framed_position = _framed_position.lerp(bounds.get_center() + FRAMING_OFFSET, weight)
	_framed_zoom = lerpf(_framed_zoom, _zoom_to_fit(bounds), weight)
	global_position = _framed_position
	zoom = Vector2.ONE * _framed_zoom * zoom_offset


func _player_bounds() -> Rect2:
	var bounds := Rect2(follow[0].global_position, Vector2.ZERO)
	for player in follow:
		bounds = bounds.expand(player.global_position)
	return bounds


func _zoom_to_fit(bounds: Rect2) -> float:
	var view := get_viewport_rect().size
	var height_needed := maxf(bounds.size.y, bounds.size.x / view.aspect()) + FRAMING_MARGIN
	return clampf(view.y / height_needed, MIN_ZOOM, MAX_ZOOM)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_zoom_in"):
		zoom_offset /= DEV_ZOOM_STEP
	elif event.is_action_pressed("dev_zoom_out"):
		zoom_offset *= DEV_ZOOM_STEP
