class_name Flashlight
extends RigidBody3D

const SPRING_FORCE: float = 300.0
const DAMPING: float = 10.0
const ROTATION_SPEED: float = 90.0
const KICK_STRENGTH: float = 2.5
const FLASH_ENERGY: float = 8.0
const FLASH_SECONDS: float = 0.1
const MAX_TARGET_DISTANCE: float = 1.5

var target_position: Node3D = null
var aim_origin: Node3D = null
var _last_target_position: Vector3

@onready var visuals: Node3D = $Visuals
@onready var hand_mesh: MeshInstance3D = $Visuals/HandOnly/flashlight_hand
@onready var shoot_position: Node3D = $ShootPosition
@onready var spot_light: SpotLight3D = $Visuals/SpotLight3D
@onready var base_light_energy: float = spot_light.light_energy


func _ready() -> void:
	gravity_scale = 0.0
	lock_rotation = true
	top_level = true


func set_color(color: Color) -> void:
	var source := hand_mesh.get_active_material(0) as BaseMaterial3D
	if source:
		var material := source.duplicate() as BaseMaterial3D
		material.albedo_color = color
		hand_mesh.set_surface_override_material(0, material)
	spot_light.light_color = color


func kick(direction: Vector3) -> void:
	apply_central_impulse(-direction * KICK_STRENGTH)
	spot_light.light_energy = FLASH_ENERGY
	create_tween().tween_property(spot_light, "light_energy", base_light_energy, FLASH_SECONDS)


func _physics_process(delta: float) -> void:
	if target_position == null or aim_origin == null:
		return

	_move_towards_target_position(delta)
	_rotate_towards_target(delta)


func _move_towards_target_position(delta: float) -> void:
	var target := target_position.global_position
	var target_velocity := (target - _last_target_position) / delta
	_last_target_position = target
	var displacement := target - global_position
	if displacement.length() > MAX_TARGET_DISTANCE:
		global_position = target
		linear_velocity = Vector3.ZERO
		return
	apply_central_force(displacement * SPRING_FORCE - (linear_velocity - target_velocity) * DAMPING)


func _rotate_towards_target(delta: float) -> void:
	var aim_direction := (target_position.global_position - aim_origin.global_position).normalized()
	var up_vector := Vector3.DOWN if aim_direction.x < 0 else Vector3.UP
	var target_basis := Basis.looking_at(aim_direction, up_vector)
	global_transform.basis = global_transform.basis.slerp(target_basis, ROTATION_SPEED * delta)
