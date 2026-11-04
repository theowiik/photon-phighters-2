class_name CrystalRegistry
extends RefCounted

const DESCRIPTIONS: Dictionary[String, String] = {
	"phast": "Run 60% faster",
	"double_jump": "Jump again in mid-air",
	"rapid_fire": "Shoot twice as often",
	"triple_shot": "Fire three bullets at once",
	"fast_bullets": "Bullets fly twice as fast",
	"recoil": "Shots knock you backwards",
	"wobbly": "Bullets weave as they fly",
}

static var movement_crystals: Dictionary[String, GDScript] = {
	"phast": PhastDecorator,
	"double_jump": DoubleJumpDecorator,
}

static var shooting_crystals: Dictionary[String, GDScript] = {
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


static func random_choices(count: int, owned: Array[String]) -> Array[String]:
	var crystals := get_all_crystals()
	for crystal in owned:
		crystals.erase(crystal)
	crystals.shuffle()
	return crystals.slice(0, count)


static func get_description(crystal_name: String) -> String:
	return DESCRIPTIONS[crystal_name]


static func is_movement_crystal(crystal_name: String) -> bool:
	return movement_crystals.has(crystal_name)


static func is_shooting_crystal(crystal_name: String) -> bool:
	return shooting_crystals.has(crystal_name)


static func create_movement_decorator(crystal_name: String, base: MoverInterface) -> MoverInterface:
	return movement_crystals[crystal_name].new(base)


static func create_shooting_decorator(
	crystal_name: String, base: ShooterInterface
) -> ShooterInterface:
	return shooting_crystals[crystal_name].new(base)
