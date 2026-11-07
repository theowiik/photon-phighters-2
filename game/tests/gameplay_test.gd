class_name GameplayTest
extends Node

var game: Main
var failed: bool = false


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	get_tree().create_timer(45.0, true, false, true).timeout.connect(_timeout)
	game = load("res://main/main.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	_expect(game.state == Main.GameState.TITLE)
	_expect(not get_tree().paused)
	_expect(game.players[0].is_bot() and game.players[1].is_bot())
	_expect(game.players[0].team.color != game.players[1].team.color)
	_press_enter()
	_expect(not game.players[0].is_bot())
	_expect(get_tree().paused)
	_expect(game.state == Main.GameState.COUNTDOWN)
	_press_enter()
	_expect(game.round_number == 1)
	await _wait_for_state(Main.GameState.PLAYING)
	for player in game.players:
		player.set_physics_process(false)
	game.players[1].input = NaiveBotInput.new(game.players[1])
	await _test_gamepad_picker()
	_test_respawn()
	_test_bulb_claim()
	await _test_bullet_skips_shooter()
	game.round_manager.reset()
	game.round_manager.start()
	game.round_manager.time_remaining = 0.01
	await _wait_for_state(Main.GameState.ROUND_OVER)
	_expect(game.round_wins[game.players[0]] == 0)
	_expect(game.round_wins[game.players[1]] == 0)
	await _wait_for_state(Main.GameState.PLAYING)
	_expect(game.round_number == 2)
	await _win_round(game.players[0])
	await _wait_for_state(Main.GameState.PICKING)
	await _wait_for_state(Main.GameState.PLAYING)
	_expect(_crystal_count(game.players[1]) == 1)
	_expect(game.round_manager.scores.is_empty())
	_expect(get_tree().get_nodes_in_group(Constants.BULBS_GROUP).is_empty())
	await _win_round(game.players[1])
	await _wait_for_state(Main.GameState.PICKING)
	var picker := game.get_node("UI/CrystalPicker") as CrystalPicker
	_expect(picker.buttons.get_child_count() == 3)
	_press_enter()
	await _wait_for_state(Main.GameState.PLAYING)
	_expect(_crystal_count(game.players[0]) == 1)
	await _win_round(game.players[0])
	await _wait_for_state(Main.GameState.PLAYING)
	await _win_round(game.players[0])
	await _wait_for_state(Main.GameState.MATCH_OVER)
	_expect(game.round_wins[game.players[0]] == Constants.ROUNDS_TO_WIN)
	_expect(get_tree().paused)
	_press_enter()
	await get_tree().scene_changed
	game = get_tree().current_scene
	_expect(game.state == Main.GameState.COUNTDOWN)
	_expect(game.round_number == 1)
	for player in game.players:
		_expect(game.round_wins[player] == 0)
		_expect(_crystal_count(player) == 0)
	if not failed:
		print(
			(
				"PASS: title, countdown, draw, scoring, bot/human picks, match win, replay, respawn,"
				+ " no self-hits"
			)
		)
	get_tree().quit(1 if failed else 0)


func _test_gamepad_picker() -> void:
	var player := game.players[0]
	var original_input := player.input
	player.input = GamepadInput.new(7)
	get_tree().paused = true
	var picker: CrystalPicker = load("res://crystals/crystal_picker.tscn").instantiate()
	add_child(picker)
	var selected: Array[String] = []
	picker.crystal_picked.connect(func(crystal: String) -> void: selected.append(crystal))
	var owned: Array[String] = ["double_jump", "rapid_fire"]
	var choices := CrystalRegistry.random_choices(3, owned)
	_expect(choices.size() == 3)
	_expect(not choices.has("double_jump") and not choices.has("rapid_fire"))
	picker.show_choices(player, choices)
	_press_enter()
	_press_gamepad(0, JOY_BUTTON_A)
	_expect(selected.is_empty())
	_press_gamepad(7, JOY_BUTTON_DPAD_DOWN)
	_press_gamepad(7, JOY_BUTTON_A)
	_expect(selected == [choices[1]])
	_press_gamepad(7, JOY_BUTTON_A)
	_expect(selected.size() == 1)
	picker.queue_free()
	await get_tree().process_frame
	player.input = original_input
	get_tree().paused = false


func _press_gamepad(device: int, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event = InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _test_respawn() -> void:
	var player := game.players[0]
	player.protection_remaining = 0.0
	player.take_damage(Player.MAX_HEALTH)
	_expect(player.is_knocked_out)
	player._physics_process(Player.RESPAWN_DELAY + 0.01)
	_expect(not player.is_knocked_out)
	_expect(player.health == Player.MAX_HEALTH)
	_expect(player.global_position == player.spawn_position)
	_expect(player.flashlight.global_position == player.flashlight.target_position.global_position)
	player.take_damage(20.0)
	_expect(player.health == Player.MAX_HEALTH)
	player.protection_remaining = 0.0
	player.take_damage(20.0)
	_expect(player.health == Player.MAX_HEALTH - 20.0)
	player.respawn()


func _test_bulb_claim() -> void:
	var bulb := _add_bulb(game.players[0].team)
	_expect(game.round_manager.get_score(game.players[0].team) == 1)
	bulb.claim(game.players[1].team)
	_expect(game.round_manager.get_score(game.players[0].team) == 0)
	_expect(game.round_manager.get_score(game.players[1].team) == 1)


func _test_bullet_skips_shooter() -> void:
	var shooter := game.players[0]
	var target := game.players[1]
	for player in game.players:
		player.protection_remaining = 0.0
	target.global_position = shooter.global_position + Vector2.RIGHT * 96.0
	_drop_bullet_on(shooter, shooter)
	_drop_bullet_on(target, shooter)
	for _frame in 20:
		await get_tree().physics_frame
	_expect(shooter.health == Player.MAX_HEALTH)
	_expect(target.health < Player.MAX_HEALTH)
	target.respawn()


func _drop_bullet_on(target: Player, shooter: Player) -> void:
	var bullet: Bullet = preload("res://bullet/bullet.tscn").instantiate()
	bullet.shooter = shooter
	bullet.team = shooter.team
	bullet.velocity = Vector2.DOWN * 960.0
	game.add_child(bullet)
	bullet.global_position = target.global_position + Vector2.UP * 128.0


func _add_bulb(team: Team) -> Bulb:
	var bulb: Bulb = preload("res://bulb/bulb.tscn").instantiate()
	bulb.set_team(team)
	game.add_child(bulb)
	return bulb


func _win_round(winner: Player) -> void:
	_add_bulb(winner.team)
	game.round_manager.time_remaining = 0.01
	await _wait_for_state(Main.GameState.ROUND_OVER)


func _wait_for_state(expected: Main.GameState) -> void:
	while game.state != expected:
		await get_tree().process_frame


func _press_enter() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ENTER
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	event = InputEventKey.new()
	event.keycode = KEY_ENTER
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _crystal_count(player: Player) -> int:
	return player.mover_decorator_names.size() + player.shooter_decorator_names.size()


func _timeout() -> void:
	push_error("Gameplay test timed out")
	get_tree().quit(1)


func _expect(condition: bool) -> void:
	if not condition:
		failed = true
		push_error("Gameplay check failed: %s" % get_stack()[1])
