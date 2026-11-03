class_name Console
extends RefCounted

var output_label: RichTextLabel
var scene_tree: SceneTree
var commands: Dictionary = {}


func _init(output: RichTextLabel, tree: SceneTree):
	output_label = output
	scene_tree = tree
	_register_commands()


func _register_commands():
	commands["apply"] = _cmd_apply
	commands["list"] = _cmd_list
	commands["help"] = _cmd_help


func execute(input: String):
	var parts = input.split(" ", false)
	if parts.size() == 0:
		return

	var command = parts[0].trim_prefix("/")
	var args = parts.slice(1)

	if commands.has(command):
		commands[command].call(args)
	else:
		write("Unknown command: " + command)
		write("Type /help for available commands")


func write(text: String):
	output_label.text += text + "\n"


func _cmd_apply(args: Array):
	if args.size() < 1:
		write("Usage: /apply <crystal_name>")
		return

	var crystal_name = args[0]
	var players = _get_players()

	if players.size() == 0:
		write("No players found")
		return

	var success_count = 0
	for player in players:
		if player.apply_crystal(crystal_name):
			success_count += 1

	if success_count > 0:
		write("Applied '%s' to %d player(s)" % [crystal_name, success_count])
	else:
		write("Failed to apply '%s' (already active or invalid)" % crystal_name)


func _cmd_list(_args: Array):
	var registry = CrystalRegistry.new()
	var crystals = registry.get_all_crystals()
	write("Available crystals:")
	for crystal in crystals:
		write("  - " + crystal)


func _cmd_help(_args: Array):
	write("Available commands:")
	write("  /apply <crystal_name> - Apply crystal to all players")
	write("  /list - List all available crystals")
	write("  /help - Show this help message")


func _get_players() -> Array:
	return scene_tree.get_nodes_in_group(Constants.PLAYERS_GROUP)
