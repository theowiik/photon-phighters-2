class_name Bulb
extends Area3D

signal bulb_hit(new_team: Team)

const POP_SECONDS: float = 0.25
const CLAIM_SCALE: float = 1.8
const CLAIM_LIGHT_ENERGY: float = 6.0

var team: Team = Team.white()
var _color_initialized := false
var _material: StandardMaterial3D

@onready var light: OmniLight3D = $OmniLight3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var base_light_energy: float = light.light_energy


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	_material.emission_energy_multiplier = 3.5
	mesh_instance.material_override = _material
	mesh_instance.scale = Vector3.ZERO
	_pop()

	if _color_initialized:
		_apply_team(team)
		bulb_hit.emit(team)


func set_team(new_team: Team) -> void:
	team = new_team
	_color_initialized = true


func get_team() -> Team:
	return team


func _apply_team(new_team: Team) -> void:
	team = new_team
	light.light_color = team.color

	if _material:
		_material.albedo_color = team.color
		_material.emission = team.color


func claim(new_team: Team) -> void:
	if team.color == new_team.color:
		return

	_apply_team(new_team)
	bulb_hit.emit(new_team)
	mesh_instance.scale = Vector3.ONE * CLAIM_SCALE
	light.light_energy = CLAIM_LIGHT_ENERGY
	_pop()


func _pop() -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(mesh_instance, "scale", Vector3.ONE, POP_SECONDS)
	tween.tween_property(light, "light_energy", base_light_energy, POP_SECONDS)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group(Constants.BULLETS_GROUP):
		claim(area.team)
		area.queue_free()
