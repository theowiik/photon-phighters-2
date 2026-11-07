class_name Flashlight
extends RigidBody2D

const SPRING_FORCE: float = 300.0
const DAMPING: float = 10.0
const KICK_STRENGTH: float = 80.0
const LENS_GLOW: float = 4.0
const FLASH_ENERGY: float = 4.0
const FLASH_SECONDS: float = 0.1
const MAX_TARGET_DISTANCE: float = 48.0

var target_position: Node2D = null
var aim_origin: Node2D = null
var _last_target_position: Vector2

@onready var visuals: Node2D = $Visuals
@onready var beam: Polygon2D = $Visuals/Beam
@onready var lens: Capsule = $Visuals/Lens
@onready var hand: Capsule = $Visuals/Hand
@onready var shoot_position: Node2D = $ShootPosition


func _ready() -> void:
	gravity_scale = 0.0
	lock_rotation = true
	top_level = true


func set_color(color: Color) -> void:
	hand.color = color
	lens.color = color * Color(LENS_GLOW, LENS_GLOW, LENS_GLOW)
	beam.self_modulate = color


func kick(direction: Vector2) -> void:
	apply_central_impulse(-direction * KICK_STRENGTH)
	beam.modulate = Color(FLASH_ENERGY, FLASH_ENERGY, FLASH_ENERGY)
	create_tween().tween_property(beam, "modulate", Color.WHITE, FLASH_SECONDS)


func _physics_process(delta: float) -> void:
	if target_position == null or aim_origin == null:
		return

	_move_towards_target_position(delta)
	_rotate_towards_target()


func _move_towards_target_position(delta: float) -> void:
	var target := target_position.global_position
	var target_velocity := (target - _last_target_position) / delta
	_last_target_position = target
	var displacement := target - global_position
	if displacement.length() > MAX_TARGET_DISTANCE:
		global_position = target
		linear_velocity = Vector2.ZERO
		return
	apply_central_force(displacement * SPRING_FORCE - (linear_velocity - target_velocity) * DAMPING)


func _rotate_towards_target() -> void:
	var aim_direction := target_position.global_position - aim_origin.global_position
	rotation = aim_direction.angle()
	visuals.scale.y = -1.0 if aim_direction.x < 0.0 else 1.0
