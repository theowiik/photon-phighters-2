class_name Console
extends RefCounted

var output_label: RichTextLabel
var commands: Dictionary[String, Callable] = {
	"apply": _cmd_apply,
	"list": _cmd_list,
	"help": _cmd_help,
}


func _init(output: RichTextLabel) -> void:
	output_label = output


func execute(input: String) -> void:
	var parts := input.split(" ", false)
	if parts.is_empty():
		return

	var command := parts[0].trim_prefix("/")
	if commands.has(command):
		commands[command].call(parts.slice(1))
	else:
		write("Unknown command: " + command)
		write("Type /help for available commands")


func write(text: String) -> void:
	output_label.text += text + "\n"


func _cmd_apply(args: PackedStringArray) -> void:
	if args.is_empty():
		write("Usage: /apply <crystal_name>")
		return

	var crystal_name := args[0]
	var players := Groups.get_all_players()
	if players.is_empty():
		write("No players found")
		return

	var success_count := 0
	for player in players:
		if player.apply_crystal(crystal_name):
			success_count += 1

	if success_count > 0:
		write("Applied '%s' to %d player(s)" % [crystal_name, success_count])
	else:
		write("Failed to apply '%s' (unknown crystal)" % crystal_name)


func _cmd_list(_args: PackedStringArray) -> void:
	write("Available crystals:")
	for crystal in CrystalRegistry.get_all_crystals():
		write("  - " + crystal)


func _cmd_help(_args: PackedStringArray) -> void:
	write("Available commands:")
	write("  /apply <crystal_name> - Apply crystal to all players")
	write("  /list - List all available crystals")
	write("  /help - Show this help message")
