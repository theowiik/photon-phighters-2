class_name FastBulletsDecorator
extends ShooterDecorator

var speed_multiplier: float = 2.0


func shoot(context: ShootingContext) -> Array[Bullet]:
	context.speed_multiplier *= speed_multiplier
	return wrapped_shooter.shoot(context)
