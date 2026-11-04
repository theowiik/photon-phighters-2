class_name Player
extends CharacterBody3D

signal damaged
signal knocked_out

const MAX_HEALTH: float = 100.0
const RESPAWN_DELAY: float = 1.5
const SPAWN_PROTECTION: float = 1.0
const HEALTH_BAR_SEGMENTS: int = 10
const BODY_GLOW: float = 0.2
const HIT_FLASH_SECONDS: float = 0.12
const PROTECTION_BLINK_SECONDS: float = 0.08

@export var display_name: String = "P1"

var team: Team
var input: InputInterface
var health: float = MAX_HEALTH
var spawn_position: Vector3
var is_knocked_out: bool = false
var respawn_time_remaining: float = 0.0
var protection_remaining: float = 0.0

# Movement
var mover: MoverInterface
var base_mover: MoverInterface
var mover_decorator_names: Array[String] = []
var jump_count: int = 0

# Shooting
var shooter: ShooterInterface
var base_shooter: ShooterInterface
var shooter_decorator_names: Array[String] = []
var shoot_cooldown: float = 0.0
var animation_manager: AnimationManager
var _body_materials: Array[BaseMaterial3D] = []

@onready var aim_pivot: Node3D = $AimPivot
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var flashlight: Flashlight = $Flashlight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: Node3D = $Body
@onready var health_label: Label3D = $HealthLabel
@onready var hurt_player: AudioStreamPlayer = $HurtPlayer
@onready var shoot_player: AudioStreamPlayer = $ShootPlayer
@onready var jump_player: AudioStreamPlayer = $JumpPlayer


func _ready():
	spawn_position = global_position
	input = KeyboardMouseInput.new(self)

	base_mover = BaseMover.new()
	mover = base_mover

	base_shooter = BaseShooter.new()
	shooter = base_shooter

	animation_manager = AnimationManager.new(animation_player, body)
	flashlight.target_position = $AimPivot/DesiredFlashlightPosition
	flashlight.aim_origin = aim_pivot

	set_team(Team.red())
	_update_health_label()


func _physics_process(delta: float) -> void:
	if is_knocked_out:
		respawn_time_remaining -= delta
		if respawn_time_remaining <= 0.0:
			respawn()
		return

	if protection_remaining > 0.0:
		protection_remaining = maxf(protection_remaining - delta, 0.0)
		body.visible = (
			protection_remaining == 0.0
			or fmod(protection_remaining, PROTECTION_BLINK_SECONDS * 2.0) > PROTECTION_BLINK_SECONDS
		)
	input.update()
	_process_shooting(delta)
	_process_movement(delta)


func _process_shooting(delta: float) -> void:
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	var aim_input = input.get_aim_direction()
	if aim_input.length() > 0:
		var angle = -atan2(aim_input.y, aim_input.x)
		aim_pivot.rotation.z = angle

	if input.is_shoot_pressed() and shoot_cooldown <= 0:
		var shoot_pos = flashlight.shoot_position.global_position
		var direction = -flashlight.global_transform.basis.z
		var context = ShootingContext.new(shoot_pos, direction, team, get_parent(), self)

		shooter.shoot(context)
		shoot_cooldown = shooter.get_shoot_delay()
		flashlight.kick(direction)
		shoot_player.pitch_scale = randf_range(0.9, 1.15)
		shoot_player.play()


func _process_movement(delta: float) -> void:
	var context = MovementContext.new(
		velocity.y, is_on_floor(), input.is_jump_just_pressed(), jump_count
	)
	context.velocity_x = velocity.x
	context.jump_held = input.is_jump_held()
	context.is_on_wall = is_on_wall()
	if context.is_on_wall:
		context.wall_normal = get_wall_normal()

	velocity = mover.process_movement(input.get_movement(), delta, context)
	jump_count = context.jump_count
	if velocity.y > context.velocity_y + 1.0:
		jump_player.play()

	var locked_z = global_position.z
	velocity.z = 0
	move_and_slide()
	global_position.z = locked_z
	velocity.z = 0

	animation_manager.update(velocity, is_on_floor(), is_on_wall(), get_wall_normal())


func is_bot() -> bool:
	return input is NaiveBotInput


func apply_impulse(impulse: Vector3) -> void:
	velocity += impulse


func take_damage(amount: float) -> void:
	if is_knocked_out or protection_remaining > 0.0:
		return

	hurt_player.play()
	damaged.emit()
	_flash()
	health = maxf(health - amount, 0.0)
	_update_health_label()
	if health == 0.0:
		knock_out()


func knock_out() -> void:
	if is_knocked_out:
		return

	is_knocked_out = true
	knocked_out.emit()
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_deferred("global_position", spawn_position)
	respawn_time_remaining = RESPAWN_DELAY


func respawn() -> void:
	is_knocked_out = false
	health = MAX_HEALTH
	respawn_time_remaining = 0.0
	protection_remaining = SPAWN_PROTECTION
	shoot_cooldown = 0.0
	jump_count = 0
	global_position = spawn_position
	velocity = Vector3.ZERO
	flashlight.global_position = flashlight.target_position.global_position
	flashlight.linear_velocity = Vector3.ZERO
	flashlight.angular_velocity = Vector3.ZERO
	visible = true
	collision_shape.set_deferred("disabled", false)
	_update_health_label()


func _update_health_label() -> void:
	var filled := ceili(health / MAX_HEALTH * HEALTH_BAR_SEGMENTS)
	health_label.text = "█".repeat(filled) + "░".repeat(HEALTH_BAR_SEGMENTS - filled)
	health_label.visible = health < MAX_HEALTH


func _flash() -> void:
	var tween := create_tween().set_parallel()
	for material in _body_materials:
		material.emission = Color.WHITE
		material.emission_energy_multiplier = 3.0
		tween.tween_property(material, "emission", team.color, HIT_FLASH_SECONDS)
		tween.tween_property(material, "emission_energy_multiplier", BODY_GLOW, HIT_FLASH_SECONDS)


func apply_crystal(crystal_name: String) -> bool:
	if CrystalRegistry.is_movement_crystal(crystal_name):
		mover_decorator_names.append(crystal_name)
		_rebuild_movement_chain()
		return true

	if CrystalRegistry.is_shooting_crystal(crystal_name):
		shooter_decorator_names.append(crystal_name)
		_rebuild_shooting_chain()
		return true

	return false


func _rebuild_movement_chain():
	mover = base_mover
	for crystal_name in mover_decorator_names:
		mover = CrystalRegistry.create_movement_decorator(crystal_name, mover)


func _rebuild_shooting_chain():
	shooter = base_shooter
	for crystal_name in shooter_decorator_names:
		shooter = CrystalRegistry.create_shooting_decorator(crystal_name, shooter)


func set_team(new_team: Team) -> void:
	team = new_team
	_apply_team_color()


func _apply_team_color() -> void:
	_body_materials.clear()
	for child in body.get_children():
		for mesh_instance in child.get_children():
			if mesh_instance is MeshInstance3D:
				var material = mesh_instance.get_active_material(0)
				if material:
					material = material.duplicate()
					material.albedo_color = team.color
					material.emission_enabled = true
					material.emission = team.color
					material.emission_energy_multiplier = BODY_GLOW
					material.rim_enabled = true
					material.rim_tint = 0.3
					mesh_instance.set_surface_override_material(0, material)
					_body_materials.append(material)

	flashlight.set_color(team.color)
	health_label.modulate = team.color
