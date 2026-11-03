class_name BaseShooter
extends ShooterInterface

var bullet_scene: PackedScene = load("res://bullet/bullet.tscn")
var bullet_speed: float = 30.0
var shoot_delay: float = 0.3


func get_shoot_delay() -> float:
	return shoot_delay


func shoot(context: ShootingContext) -> Array[Bullet]:
	if context.bullet_scene == null:
		context.bullet_scene = bullet_scene

	if context.bullet_speed == 0:
		context.bullet_speed = bullet_speed * context.speed_multiplier

	var total_bullets = 1 + context.extra_shots
	var bullets: Array[Bullet] = []

	for i in range(total_bullets):
		var spread_offset = randf_range(-context.spread, context.spread)
		var shot_dir = context.direction.rotated(Vector3.FORWARD, deg_to_rad(spread_offset))
		var bullet = spawn_bullet(
			context.from_position, shot_dir, context.team, context.parent, context
		)
		bullets.append(bullet)

	return bullets


func spawn_bullet(
	from_position: Vector3, direction: Vector3, team: Team, parent: Node, context: ShootingContext
) -> Bullet:
	var bullet: Bullet = context.bullet_scene.instantiate()
	bullet.position = from_position
	bullet.speed = context.bullet_speed
	bullet.set_direction(direction)
	bullet.team = team
	parent.add_child(bullet)
	return bullet
