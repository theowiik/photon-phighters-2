class_name CrystalPicker
extends Control

signal crystal_picked(crystal_name: String)
var crystal_button_scene: PackedScene = preload("res://crystals/crystal_button.tscn")

@onready var result_label: RichTextLabel = $Content/ResultLabel
@onready var buttons: VBoxContainer = $Content/Buttons


func _ready() -> void:
	_spawn_buttons()


func show_result(winner: Player, loser: Player) -> void:
	result_label.bbcode_enabled = true

	var winner_hex: String = winner.team.get_hex()
	var loser_hex: String = loser.team.get_hex()

	var text: String = (
		"[color=#%s]%s[/color] wins!\n[color=#%s]%s[/color] picks a crystal"
		% [winner_hex, winner.team.name, loser_hex, loser.team.name]
	)
	result_label.text = text


func _spawn_buttons() -> void:
	for crystal_name in CrystalRegistry.new().get_all_crystals():
		var button = crystal_button_scene.instantiate()
		button.text = crystal_name.capitalize()
		buttons.add_child(button)
		button.pressed.connect(_on_crystal_button_pressed.bind(crystal_name))


func _on_crystal_button_pressed(crystal_name: String) -> void:
	crystal_picked.emit(crystal_name)
