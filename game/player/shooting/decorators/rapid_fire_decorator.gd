class_name RapidFireDecorator
extends ShooterDecorator

const DELAY_MULTIPLIER: float = 0.5


func get_shoot_delay() -> float:
	return wrapped_shooter.get_shoot_delay() * DELAY_MULTIPLIER
