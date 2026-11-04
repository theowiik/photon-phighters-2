class_name Main
extends Node3D

enum GameState { TITLE, COUNTDOWN, PLAYING, ROUND_OVER, PICKING, MATCH_OVER }

const INTRO_SECONDS: float = 1.1
const GO_SECONDS: float = 0.5
const ROUND_OVER_SECONDS: float = 2.0
const CRYSTAL_CHOICES: int = 3

static var has_shown_title: bool = false

var crystal_picker_scene: PackedScene = load("res://crystals/crystal_picker.tscn")
var state: GameState = GameState.TITLE
var round_number: int = 0
var round_wins: Dictionary[Player, int] = {}

@onready var hud: HUD = $HUD
@onready var round_manager: RoundManager = $RoundManager
@onready var players: Array[Player] = [$Player1, $Player2]


func _ready() -> void:
	_assign_teams()
	_assign_inputs()
	for player in players:
		round_wins[player] = 0

	round_manager.players = players
	round_manager.time_updated.connect(hud.update_time)
	round_manager.scores_updated.connect(hud.update_scores)
	round_manager.round_finished.connect(_on_round_finished)
	hud.start_requested.connect(_on_start_requested)
	hud.setup(players, round_wins)

	if has_shown_title:
		_start_round()
	else:
		_show_title()


func _assign_teams() -> void:
	var teams := Team.contrasting_pair()
	for i in players.size():
		players[i].set_team(teams[i])


func _assign_inputs() -> void:
	var gamepads := Input.get_connected_joypads()
	players[0].input = KeyboardMouseInput.new(players[0].aim_pivot)
	if gamepads.is_empty():
		players[1].input = NaiveBotInput.new(players[1])
	else:
		players[1].input = GamepadInput.new(gamepads[0])


func _set_state(new_state: GameState) -> void:
	state = new_state
	get_tree().paused = state not in [GameState.TITLE, GameState.PLAYING]


func _show_title() -> void:
	_set_state(GameState.TITLE)
	for player in players:
		player.input = NaiveBotInput.new(player)
	round_manager.reset()
	hud.show_title(_controls_text())


func _controls_text() -> String:
	var player_two := "Left stick move · A jump · Right stick aim · RT shoot"
	if Input.get_connected_joypads().is_empty():
		player_two = "Bot · connect a gamepad to play against a friend"
	return (
		"P1  A/D move · W or Space jump · Mouse aim · Click shoot\nP2  %s\nFirst to %d rounds"
		% [player_two, Constants.ROUNDS_TO_WIN]
	)


func _on_start_requested() -> void:
	match state:
		GameState.TITLE:
			_assign_inputs()
			has_shown_title = true
			_start_round()
		GameState.MATCH_OVER:
			get_tree().reload_current_scene()


func _start_round() -> void:
	round_number += 1
	round_manager.reset()
	for player in players:
		player.respawn()

	_set_state(GameState.COUNTDOWN)
	hud.show_scoreboard()
	hud.show_banner("ROUND %d" % round_number)
	await get_tree().create_timer(INTRO_SECONDS).timeout

	hud.flash_banner("GO!", GO_SECONDS)
	_set_state(GameState.PLAYING)
	round_manager.start()


func _on_round_finished(winner: Player, loser: Player) -> void:
	_set_state(GameState.ROUND_OVER)

	if winner == null:
		hud.show_banner("DRAW", _bulb_score_line())
		await get_tree().create_timer(ROUND_OVER_SECONDS).timeout
		_start_round()
		return

	round_wins[winner] += 1
	hud.update_round_wins(round_wins)
	hud.show_banner(
		"%s TAKES THE ROUND" % winner.team.name.to_upper(), _bulb_score_line(), winner.team.color
	)
	await get_tree().create_timer(ROUND_OVER_SECONDS).timeout

	if round_wins[winner] >= Constants.ROUNDS_TO_WIN:
		_end_match(winner)
	else:
		_offer_crystals(loser)


func _bulb_score_line() -> String:
	return _versus_line(
		round_manager.get_score(players[0].team), round_manager.get_score(players[1].team)
	)


func _versus_line(left: int, right: int) -> String:
	return "%s %d  –  %d %s" % [players[0].team.name, left, right, players[1].team.name]


func _offer_crystals(loser: Player) -> void:
	_set_state(GameState.PICKING)
	hud.hide_banner()

	var picker: CrystalPicker = crystal_picker_scene.instantiate()
	add_child(picker)
	picker.crystal_picked.connect(_on_crystal_picked.bind(loser, picker))
	var owned := loser.mover_decorator_names + loser.shooter_decorator_names
	picker.show_choices(loser, CrystalRegistry.random_choices(CRYSTAL_CHOICES, owned))


func _on_crystal_picked(crystal_name: String, loser: Player, picker: CrystalPicker) -> void:
	loser.apply_crystal(crystal_name)
	hud.update_loadouts()
	hud.add_log("%s picked %s" % [loser.display_name, crystal_name.capitalize()])
	picker.queue_free()
	_start_round()


func _end_match(winner: Player) -> void:
	_set_state(GameState.MATCH_OVER)
	var final_score := _versus_line(round_wins[players[0]], round_wins[players[1]])
	hud.show_banner("%s WINS" % winner.team.name.to_upper(), final_score, winner.team.color, true)
	hud.wait_for_start("Press Enter or A to play again")


func _on_ob_body_entered(body: Node3D) -> void:
	if body is Player:
		body.knock_out()
