class_name PlayerBody
extends Node3D

const GLOW: float = 0.2
const RIM_TINT: float = 0.3
const FLASH_GLOW: float = 3.0
const FLASH_SECONDS: float = 0.12

var _color: Color = Color.WHITE
var _materials: Array[BaseMaterial3D] = []


func set_color(color: Color) -> void:
	_color = color
	_materials.clear()
	for part in get_children():
		for mesh_instance in part.get_children():
			if mesh_instance is MeshInstance3D:
				_paint(mesh_instance)


func flash() -> void:
	var tween := create_tween().set_parallel()
	for material in _materials:
		material.emission = Color.WHITE
		material.emission_energy_multiplier = FLASH_GLOW
		tween.tween_property(material, "emission", _color, FLASH_SECONDS)
		tween.tween_property(material, "emission_energy_multiplier", GLOW, FLASH_SECONDS)


func _paint(mesh_instance: MeshInstance3D) -> void:
	var source := mesh_instance.get_active_material(0) as BaseMaterial3D
	if source == null:
		return

	var material := source.duplicate() as BaseMaterial3D
	material.albedo_color = _color
	material.emission_enabled = true
	material.emission = _color
	material.emission_energy_multiplier = GLOW
	material.rim_enabled = true
	material.rim_tint = RIM_TINT
	mesh_instance.set_surface_override_material(0, material)
	_materials.append(material)
