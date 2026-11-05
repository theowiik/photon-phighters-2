class_name FastBulletsDecorator
extends ShooterDecorator

const SPEED_MULTIPLIER: float = 2.0


func shoot(context: ShootingContext) -> Array[Bullet]:
	context.speed_multiplier *= SPEED_MULTIPLIER
	return wrapped_shooter.shoot(context)
