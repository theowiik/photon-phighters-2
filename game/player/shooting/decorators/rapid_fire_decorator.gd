class_name RapidFireDecorator
extends ShooterDecorator

var delay_multiplier: float = 0.5


func get_shoot_delay() -> float:
	return wrapped_shooter.get_shoot_delay() * delay_multiplier
