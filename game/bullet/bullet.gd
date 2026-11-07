class_name Bullet
extends Area3D

const BULB_SCENE: PackedScene = preload("res://bulb/bulb.tscn")
const HIT_BURST_SCENE: PackedScene = preload("res://player/hit_burst.tscn")
const BULB_MERGE_RADIUS: float = 0.75
const GRAVITY: float = 90.0
const WOBBLE_FREQUENCY: float = 12.0
const HIT_KNOCKBACK: float = 4.5

var team: Team = Team.white()
var shooter: Player
var velocity: Vector3 = Vector3.ZERO
var damage: float = 10.0
var wobble_amount: float = 0.0
var _age: float = 0.0
var _material: StandardMaterial3D
var _hit: bool = false

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var light: OmniLight3D = $OmniLight3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _shape_query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	_material.emission_energy_multiplier = 6.0
	_material.albedo_color = team.color
	_material.emission = team.color
	mesh_instance.material_override = _material
	light.light_color = team.color

	_shape_query.shape = collision_shape.shape
	_shape_query.collision_mask = collision_mask
	if shooter:
		_shape_query.exclude = [shooter.get_rid()]


func _physics_process(delta: float) -> void:
	if _age == 0.0 and shooter and _sweep_barrel():
		return

	_age += delta
	velocity.y -= GRAVITY * delta
	var movement: Vector3 = velocity * delta + _wobble_offset(delta)
	_align_to(movement)
	if not _sweep(global_position, movement):
		position += movement


## Sweeps from the shooter's aim pivot to the muzzle, so targets and walls closer than the
## muzzle are hit instead of skipped.
func _sweep_barrel() -> bool:
	var pivot := shooter.aim_pivot.global_position
	return _sweep(pivot, global_position - pivot)


## Returns true when the sweep was stopped, after handling any hit.
func _sweep(from: Vector3, motion: Vector3) -> bool:
	_shape_query.transform = Transform3D(global_basis, from)
	_shape_query.motion = motion

	var space_state := get_world_3d().direct_space_state
	var hit_fraction: float = space_state.cast_motion(_shape_query)[1]
	if hit_fraction >= 1.0:
		return false

	_shape_query.transform.origin += motion * hit_fraction
	_shape_query.motion = Vector3.ZERO
	var contact := space_state.get_rest_info(_shape_query)
	if contact:
		global_position = contact.point
		_handle_hit(instance_from_id(contact.collider_id))
	return true


func _align_to(direction: Vector3) -> void:
	var forward := direction.normalized()
	mesh_instance.basis = Basis(forward.cross(Vector3.BACK), forward, Vector3.BACK)


func _wobble_offset(delta: float) -> Vector3:
	var sideways := Vector3(-velocity.y, velocity.x, 0).normalized()
	return sideways * cos(_age * WOBBLE_FREQUENCY) * wobble_amount * WOBBLE_FREQUENCY * delta


func _handle_hit(body: Node3D) -> void:
	if _hit or not is_inside_tree():
		return
	_hit = true
	set_deferred("monitoring", false)

	if body is Player:
		body.take_damage(damage)
		body.apply_impulse(velocity.normalized() * HIT_KNOCKBACK)
		_spawn_hit_burst()
	else:
		_paint()

	queue_free()


func _spawn_hit_burst() -> void:
	var burst: ParticleBurst = HIT_BURST_SCENE.instantiate()
	burst.color = team.color
	burst.direction = velocity.normalized()
	get_tree().current_scene.add_child(burst)
	burst.global_position = global_position


func _paint() -> void:
	var nearby_bulb := _find_bulb_near(global_position)
	if nearby_bulb:
		nearby_bulb.claim(team)
		return

	var bulb: Bulb = BULB_SCENE.instantiate()
	bulb.set_team(team)
	get_tree().current_scene.add_child(bulb)
	bulb.global_position = global_position


func _find_bulb_near(point: Vector3) -> Bulb:
	for bulb in Groups.get_all_bulbs():
		if bulb.global_position.distance_to(point) < BULB_MERGE_RADIUS:
			return bulb
	return null


func _on_life_timer_timeout() -> void:
	queue_free()
