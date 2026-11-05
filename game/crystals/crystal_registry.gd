class_name CrystalRegistry
extends RefCounted

static var movement_crystals = {
	"phast": PhastDecorator,
	"double_jump": DoubleJumpDecorator,
}

static var shooting_crystals = {
	"rapid_fire": RapidFireDecorator,
	"triple_shot": TripleShotDecorator,
	"fast_bullets": FastBulletsDecorator,
	"recoil": RecoilDecorator,
	"wobbly": WobblyBulletsDecorator,
}


static func get_all_crystals() -> Array[String]:
	var all: Array[String] = []
	all.append_array(movement_crystals.keys())
	all.append_array(shooting_crystals.keys())
	return all


static func is_movement_crystal(crystal_name: String) -> bool:
	return movement_crystals.has(crystal_name)


static func is_shooting_crystal(crystal_name: String) -> bool:
	return shooting_crystals.has(crystal_name)


static func create_movement_decorator(crystal_name: String, base: MoverInterface) -> MoverInterface:
	if not movement_crystals.has(crystal_name):
		return null
	return movement_crystals[crystal_name].new(base)


static func create_shooting_decorator(
	crystal_name: String, base: ShooterInterface
) -> ShooterInterface:
	if not shooting_crystals.has(crystal_name):
		return null

	return shooting_crystals[crystal_name].new(base)
