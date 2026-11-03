class_name Player
extends CharacterBody3D

const MAX_HEALTH: float = 100.0
const RESPAWN_DELAY: float = 1.5
const HEALTH_BAR_SEGMENTS: int = 10

@export var display_name: String = "P1"

var team: Team
var input: InputInterface
var health: float = MAX_HEALTH
var spawn_position: Vector3
var is_knocked_out: bool = false

# Movement
var mover: MoverInterface
var base_mover: MoverInterface
var mover_decorator_names: Array[String] = []
var jump_count: int = 0
var external_velocity: Vector3 = Vector3.ZERO

# Shooting
var shooter: ShooterInterface
var base_shooter: ShooterInterface
var shooter_decorator_names: Array[String] = []
var shoot_cooldown: float = 0.0
var animation_manager: AnimationManager

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

	base_mover = BaseMover.new(5.0)
	mover = base_mover

	base_shooter = BaseShooter.new()
	shooter = base_shooter

	animation_manager = AnimationManager.new(animation_player, body)
	flashlight.target_position = $AimPivot/DesiredFlashlightPosition
	flashlight.aim_origin = aim_pivot

	set_team(Team.red())
	_update_health_label()


func _physics_process(delta):
	if is_knocked_out:
		return

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
		shoot_player.play()


func _process_movement(delta: float) -> void:
	var context = MovementContext.new(
		velocity.y, is_on_floor(), input.is_jump_just_pressed(), jump_count
	)
	context.is_on_wall = is_on_wall()
	if context.is_on_wall:
		context.wall_normal = get_wall_normal()

	velocity = mover.process_movement(input.get_movement(), delta, context)
	jump_count = context.jump_count
	if velocity.y > context.velocity_y + 1.0:
		jump_player.play()

	velocity += external_velocity
	external_velocity = external_velocity.lerp(Vector3.ZERO, 10.0 * delta)
	if external_velocity.length() < 0.1:
		external_velocity = Vector3.ZERO

	var locked_z = global_position.z
	velocity.z = 0
	move_and_slide()
	global_position.z = locked_z
	velocity.z = 0

	animation_manager.update(velocity, is_on_floor(), is_on_wall(), get_wall_normal())


func apply_impulse(impulse: Vector3) -> void:
	external_velocity += impulse


func take_damage(amount: float) -> void:
	if is_knocked_out:
		return

	hurt_player.play()
	health = maxf(health - amount, 0.0)
	_update_health_label()
	if health == 0.0:
		knock_out()


func knock_out() -> void:
	if is_knocked_out:
		return

	is_knocked_out = true
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_deferred("global_position", spawn_position)
	get_tree().create_timer(RESPAWN_DELAY).timeout.connect(_respawn_if_knocked_out)


func respawn() -> void:
	is_knocked_out = false
	health = MAX_HEALTH
	global_position = spawn_position
	velocity = Vector3.ZERO
	external_velocity = Vector3.ZERO
	visible = true
	collision_shape.set_deferred("disabled", false)
	_update_health_label()


func _respawn_if_knocked_out() -> void:
	if is_knocked_out:
		respawn()


func _update_health_label() -> void:
	var filled := ceili(health / MAX_HEALTH * HEALTH_BAR_SEGMENTS)
	var bar := "█".repeat(filled) + "░".repeat(HEALTH_BAR_SEGMENTS - filled)
	health_label.text = "%s %s" % [display_name, bar]


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
	for child in body.get_children():
		for mesh_instance in child.get_children():
			if mesh_instance is MeshInstance3D:
				var material = mesh_instance.get_active_material(0)
				if material:
					material = material.duplicate()
					material.albedo_color = team.color
					mesh_instance.set_surface_override_material(0, material)

	flashlight.set_color(team.color)
	health_label.modulate = team.color
