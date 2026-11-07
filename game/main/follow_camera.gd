class_name FollowCamera
extends Camera2D

const MIN_ZOOM: float = 0.6
const MAX_ZOOM: float = 1.8
const FRAMING_MARGIN: float = 448.0
const FRAMING_OFFSET: Vector2 = Vector2(0.0, -32.0)
const MAX_SHAKE: float = 28.0
const SHAKE_DECAY: float = 2.5
const SHAKE_SPEED: float = 40.0
const HIT_TRAUMA: float = 0.25
const KNOCK_OUT_TRAUMA: float = 0.6
const DEV_ZOOM_STEP: float = 1.25

@export var smoothing_speed: float = 4.0
var follow: Array[Player] = []
var zoom_offset: float = 1.0
var trauma: float = 0.0
var _framed_position: Vector2
var _framed_zoom: float
var _shake_time: float = 0.0
var _noise := FastNoiseLite.new()


func _ready() -> void:
	follow = Groups.get_all_players()
	for player in follow:
		player.damaged.connect(add_trauma.bind(HIT_TRAUMA))
		player.knocked_out.connect(add_trauma.bind(KNOCK_OUT_TRAUMA))
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
	trauma = maxf(trauma - SHAKE_DECAY * delta, 0.0)
	_shake_time += delta * SHAKE_SPEED
	global_position = _framed_position + _shake_offset()
	zoom = Vector2.ONE * _framed_zoom * zoom_offset


func add_trauma(amount: float) -> void:
	trauma = minf(trauma + amount, 1.0)


func _player_bounds() -> Rect2:
	var bounds := Rect2(follow[0].global_position, Vector2.ZERO)
	for player in follow:
		bounds = bounds.expand(player.global_position)
	return bounds


func _zoom_to_fit(bounds: Rect2) -> float:
	var view := get_viewport_rect().size
	var height_needed := maxf(bounds.size.y, bounds.size.x / view.aspect()) + FRAMING_MARGIN
	return clampf(view.y / height_needed, MIN_ZOOM, MAX_ZOOM)


func _shake_offset() -> Vector2:
	var strength := trauma * trauma * MAX_SHAKE
	var x := _noise.get_noise_2d(_shake_time, 0.0)
	var y := _noise.get_noise_2d(0.0, _shake_time)
	return Vector2(x, y) * strength


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_zoom_in"):
		zoom_offset /= DEV_ZOOM_STEP
	elif event.is_action_pressed("dev_zoom_out"):
		zoom_offset *= DEV_ZOOM_STEP
