class_name TripleShotDecorator
extends ShooterDecorator


func shoot(context: ShootingContext) -> Array[Bullet]:
	context.extra_shots += 2
	return wrapped_shooter.shoot(context)
