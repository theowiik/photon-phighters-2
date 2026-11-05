class_name FollowCamera
extends Camera3D

const MIN_DISTANCE: float = 32.0
const MAX_DISTANCE: float = 95.0
const FRAMING_MARGIN: float = 14.0
const MAX_SHAKE: float = 0.9
const SHAKE_DECAY: float = 2.5
const SHAKE_SPEED: float = 40.0
const HIT_TRAUMA: float = 0.25
const KNOCK_OUT_TRAUMA: float = 0.6

@export var smoothing_speed: float = 4.0
var follow: Array[Player] = []
var zoom_offset: float = 0.0
var trauma: float = 0.0
var _framed_position: Vector3
var _shake_time: float = 0.0
var _noise := FastNoiseLite.new()


func _ready() -> void:
	follow = Groups.get_all_players()
	for player in follow:
		player.damaged.connect(add_trauma.bind(HIT_TRAUMA))
		player.knocked_out.connect(add_trauma.bind(KNOCK_OUT_TRAUMA))
	_framed_position = _framing_target()
	global_position = _framed_position


func _physics_process(delta: float) -> void:
	var weight := 1.0 - exp(-smoothing_speed * delta)
	_framed_position = _framed_position.lerp(_framing_target(), weight)
	trauma = maxf(trauma - SHAKE_DECAY * delta, 0.0)
	_shake_time += delta * SHAKE_SPEED
	global_position = _framed_position + _shake_offset()


func add_trauma(amount: float) -> void:
	trauma = minf(trauma + amount, 1.0)


func _framing_target() -> Vector3:
	var bounds := AABB(follow[0].global_position, Vector3.ZERO)
	for player in follow:
		bounds = bounds.expand(player.global_position)

	var aspect := get_viewport().get_visible_rect().size.aspect()
	var height_needed := maxf(bounds.size.y, bounds.size.x / aspect) + FRAMING_MARGIN
	var distance := height_needed / (2.0 * tan(deg_to_rad(fov) / 2.0))
	distance = clampf(distance, MIN_DISTANCE, MAX_DISTANCE) + zoom_offset
	return bounds.get_center() + Vector3(0, 1.0, distance)


func _shake_offset() -> Vector3:
	var strength := trauma * trauma * MAX_SHAKE
	var x := _noise.get_noise_2d(_shake_time, 0.0)
	var y := _noise.get_noise_2d(0.0, _shake_time)
	return Vector3(x, y, 0.0) * strength


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_zoom_in"):
		zoom_offset += 10
	elif event.is_action_pressed("dev_zoom_out"):
		zoom_offset -= 10
