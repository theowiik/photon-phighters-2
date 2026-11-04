class_name Bullet
extends Area3D

const BULB_SCENE: PackedScene = preload("res://bulb/bulb.tscn")
const BULB_MERGE_RADIUS: float = 0.75
const WOBBLE_FREQUENCY: float = 12.0
const HIT_KNOCKBACK: float = 4.5

var team: Team = Team.white()
var velocity: Vector3 = Vector3.ZERO
var speed: float = 10.0
var lifetime: float = 3.0
var damage: float = 10.0
var wobble_amount: float = 0.0
var _age: float = 0.0
var _gravity: float = 3
var _material: StandardMaterial3D
var _hit: bool = false

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var light: OmniLight3D = $OmniLight3D
@onready var _ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()


func _ready():
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	_material.emission_energy_multiplier = 6.0
	mesh_instance.material_override = _material

	_ray_query.collision_mask = collision_mask
	_ray_query.collide_with_areas = false
	_ray_query.collide_with_bodies = true

	_apply_team_color()
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()


func _physics_process(delta: float) -> void:
	_age += delta
	velocity.y -= _gravity * delta
	var movement: Vector3 = velocity * speed * delta + _wobble_offset(delta)
	_align_to(movement)

	_ray_query.from = global_position
	_ray_query.to = global_position + movement

	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(_ray_query)

	if result:
		global_position = result.position
		_handle_hit(result.collider)
	else:
		position += movement


func _align_to(direction: Vector3) -> void:
	var forward := direction.normalized()
	mesh_instance.basis = Basis(forward.cross(Vector3.BACK), forward, Vector3.BACK)


func _wobble_offset(delta: float) -> Vector3:
	var sideways := Vector3(-velocity.y, velocity.x, 0).normalized()
	return sideways * cos(_age * WOBBLE_FREQUENCY) * wobble_amount * WOBBLE_FREQUENCY * delta


func set_direction(direction: Vector3):
	velocity = direction.normalized()


func _apply_team_color() -> void:
	if _material:
		_material.albedo_color = team.color
		_material.emission = team.color

	if light:
		light.light_color = team.color


func _handle_hit(body: Node3D) -> void:
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


func _find_bulb_near(point: Vector3) -> Bulb:
	for bulb in Groups.get_all_bulbs():
		if bulb.global_position.distance_to(point) < BULB_MERGE_RADIUS:
			return bulb
	return null


func _on_life_timer_timeout() -> void:
	queue_free()
