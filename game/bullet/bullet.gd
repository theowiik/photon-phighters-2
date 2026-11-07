class_name Bullet
extends Area2D

const BULB_SCENE: PackedScene = preload("res://bulb/bulb.tscn")
const BULB_MERGE_RADIUS: float = 24.0
const GRAVITY: float = 2880.0
const WOBBLE_FREQUENCY: float = 12.0
const HIT_KNOCKBACK: float = 144.0

var team: Team = Team.white()
var shooter: Player
var velocity: Vector2 = Vector2.ZERO
var damage: float = 10.0
var wobble_amount: float = 0.0
var _age: float = 0.0
var _hit: bool = false

@onready var core: Capsule = $Core
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _shape_query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()


func _ready() -> void:
	core.color = team.color

	_shape_query.shape = collision_shape.shape
	_shape_query.collision_mask = collision_mask
	if shooter:
		_shape_query.exclude = [shooter.get_rid()]


func _physics_process(delta: float) -> void:
	if _age == 0.0 and shooter and _sweep_barrel():
		return

	_age += delta
	velocity.y += GRAVITY * delta
	var movement: Vector2 = velocity * delta + _wobble_offset(delta)
	_align_to(movement)
	if not _sweep(global_position, movement):
		position += movement


## Sweeps from the shooter's aim pivot to the muzzle, so targets and walls closer than the
## muzzle are hit instead of skipped.
func _sweep_barrel() -> bool:
	var pivot := shooter.aim_pivot.global_position
	return _sweep(pivot, global_position - pivot)


## Returns true when the sweep was stopped, after handling any hit.
func _sweep(from: Vector2, motion: Vector2) -> bool:
	_shape_query.transform = Transform2D(0.0, from)
	_shape_query.motion = motion

	var space_state := get_world_2d().direct_space_state
	var hit_fraction: float = space_state.cast_motion(_shape_query)[1]
	if hit_fraction >= 1.0:
		return false

	_shape_query.transform.origin += motion * hit_fraction
	_shape_query.motion = Vector2.ZERO
	var contact := space_state.get_rest_info(_shape_query)
	if contact:
		global_position = contact.point
		_handle_hit(instance_from_id(contact.collider_id))
	return true


func _align_to(direction: Vector2) -> void:
	core.rotation = direction.angle()


func _wobble_offset(delta: float) -> Vector2:
	var sideways := Vector2(-velocity.y, velocity.x).normalized()
	return sideways * cos(_age * WOBBLE_FREQUENCY) * wobble_amount * WOBBLE_FREQUENCY * delta


func _handle_hit(body: Node2D) -> void:
	if _hit or not is_inside_tree():
		return
	_hit = true
	set_deferred("monitoring", false)

	if body is Player:
		body.take_damage(damage)
		body.apply_impulse(velocity.normalized() * HIT_KNOCKBACK)
	else:
		_paint()

	queue_free()


func _paint() -> void:
	var nearby_bulb := _find_bulb_near(global_position)
	if nearby_bulb:
		nearby_bulb.claim(team)
		return

	var bulb: Bulb = BULB_SCENE.instantiate()
	bulb.set_team(team)
	get_tree().current_scene.add_child(bulb)
	bulb.global_position = global_position


func _find_bulb_near(point: Vector2) -> Bulb:
	for bulb in Groups.get_all_bulbs():
		if bulb.global_position.distance_to(point) < BULB_MERGE_RADIUS:
			return bulb
	return null


func _on_life_timer_timeout() -> void:
	queue_free()
