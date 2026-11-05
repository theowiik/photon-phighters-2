class_name BaseShooter
extends ShooterInterface

const BULLET_SPEED: float = 30.0
const SHOOT_DELAY: float = 0.3

var bullet_scene: PackedScene = load("res://bullet/bullet.tscn")


func get_shoot_delay() -> float:
	return SHOOT_DELAY


func shoot(context: ShootingContext) -> Array[Bullet]:
	var bullets: Array[Bullet] = []
	for _shot in 1 + context.extra_shots:
		var spread := deg_to_rad(randf_range(-context.spread, context.spread))
		bullets.append(_spawn_bullet(context, context.direction.rotated(Vector3.FORWARD, spread)))
	return bullets


func _spawn_bullet(context: ShootingContext, direction: Vector3) -> Bullet:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.position = context.from_position
	bullet.velocity = direction.normalized() * BULLET_SPEED * context.speed_multiplier
	bullet.team = context.team
	context.parent.add_child(bullet)
	return bullet
