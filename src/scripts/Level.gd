extends Control
class_name Level

# Scenes

onready var enemy_scene := preload("res://src/actors/Enemy.tscn")
onready var enemy_rain_scene := preload("res://src/actors/EnemyRain.tscn")
onready var coin_scene := preload("res://src/actors/Coin.tscn")
onready var coin_bonus_scene := preload("res://src/actors/CoinBonus.tscn")
onready var bonus_scene := preload("res://src/actors/Bonus.tscn")

var score := 0
var score_max := 0
var resume_counter := 3
var current_enemies := []
var game_state := "pattern"
var game_start_time := 0
var game_pause_time_start := 0
var game_pause_time_total := 0
var next_scene := String()

# Parameters
var game_coin = 0
var game_bonus = false
var game_pattern = false
var game_rain = false


# Process

func _ready() -> void:
	# Set music
	if MusicController.current_track != "game":
		MusicController.set_track_menu("game")
	# Set player
	$Player.life = Globals.parameters.get_value(Globals.game_mode_selected, "player_life")
	$Control/Lifebar.set_max_life($Player.life)

	# Game mode dependent
	load_game_mode()

	# Reset stats
	Stats.reset()

	# Fade out to display the game
	$Control/FadeTransition.fade_out()
	# Wait for user to jump once in ordre to start the scene
	set_process(false)

# User events

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump_left"):
		$Player.jump_left()
	elif event.is_action_pressed("jump_right"):
		$Player.jump_right()
	elif event.is_action_released("pause"):
		_on_PauseButton_pressed()


func _on_TouchLeft_pressed() -> void:
	$Player.jump_left()


func _on_TouchRight_pressed() -> void:
	$Player.jump_right()

# Pause menu

func _on_PauseButton_pressed() -> void:
	get_tree().paused = true
	game_pause_time_start = OS.get_ticks_msec()
	$PauseMenu.show()
	$PauseMenu/MarginContainer/VBoxContainer/ResumeButton.grab_focus()


func _on_ResumeButton_pressed() -> void:
	$PauseMenu.hide()
	$Control/ResumeCounter.text = str(resume_counter)
	$Timers/ResumeTimer.start()


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	$PauseMenu.hide()
	get_tree().reload_current_scene()


func _on_MainMenuButton_pressed() -> void:
	get_tree().paused = false
	$PauseMenu.hide()
	next_scene = "res://src/actors/MainMenu.tscn"
	$Control/FadeTransition.fade_in()


func _on_ResumeTimer_timeout() -> void:
	resume_counter -= 1
	if resume_counter > 0:
		$Control/ResumeCounter.text = str(resume_counter)
	elif resume_counter == 0:
		$Control/ResumeCounter.text = "LABEL_RESUME_GO"
	else:
		$Control/ResumeCounter.text = ""
		# Reset resume timer
		resume_counter = 3
		$Timers/ResumeTimer.stop()
		if $Player.first_move:
			game_pause_time_total += OS.get_ticks_msec() - game_pause_time_start
		get_tree().paused = false

# Transition

func _on_FadeTransition_animation_finished(anim_name) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)

# Player

func _on_Player_first_jump() -> void:
	# Hide instructions
	$Control/Instruction.hide()
	# Create enemies
	Globals.velocity_multiplier = 1.0
	if game_pattern:
		add_random_pattern()
	# Create coin
	add_coins(1)
	# Set timers
	if game_bonus:
		$Timers/BonusTimer.start()
	if game_rain:
		$Timers/RainStartTimer.start()
	# Start game
	set_process(true)
	game_start_time = OS.get_ticks_msec()


func _on_Player_lose_life() -> void:
	$Control/Lifebar.set_life($Player.life)
	if $Player.life <= 0:
		on_death()

# Pattern

func _on_Enemy_tree_exited() -> void:
	if game_state == "pattern" and $Pattern.get_child_count() <= 0:
		Stats.patterns_dodged += 1
		add_random_pattern()


func add_random_pattern() -> void:
	"""
	Add a random pattern on the scene.
	"""

	print("Enemy speed multiplier: ", Globals.velocity_multiplier)
	var i = round(rand_range(0, Globals.enemy_patterns.size() - 1))
	current_enemies = load_pattern(Globals.enemy_patterns, i)
	for e in current_enemies:
		$Pattern.add_child(e)
	# Increase speed for next pattern
	Globals.velocity_multiplier += Globals.parameters.get_value("GAMEPLAY", "velocity_multiplier")


func load_pattern(patterns, i: int) -> Array:
	"""
	Load a single pattern.
	"""

	var array = []
	for enemy in patterns[i]:
		var p = Vector2(enemy["position"][0], enemy["position"][1])
		var v = Vector2(enemy["velocity"][0], enemy["velocity"][1])
		var e = enemy_scene.instance()
		e.position = p
		e.velocity = v * Globals.velocity_multiplier
		e.connect("tree_exited", self, "_on_Enemy_tree_exited")
		array.append(e)

	return array

# Rain

func _on_RainStartTimer_timeout() -> void:
	"""
	Step 1: Prepare rain and show warning.

	Stop the bonus timer.
	TODO: Remove coins and bonus.
	Start alert animation
	"""

	if game_bonus:
		$Timers/BonusTimer.paused = true

	$Control/Warning/Label.show()
	$Control/Warning/ColorRect/WarningAnimation.play("alert_on")
	game_state = "rain"


func _on_WarningAnimation_animation_finished(anim_name: String) -> void:
	"""
	Step 2: after warning, start rain.
	Step 5: after rain, spawn coins.
	"""

	# Step 2
	if anim_name == "alert_on":
		$Control/Warning/Label.hide()
		for torch in $Torches.get_children():
			torch.set_alert(true)
		$Timers/RainSpawnTimer.start()
		$Timers/RainStopTimer.start()
	# Step 5
	elif anim_name == "alert_off":
		add_bonus_coins(Globals.parameters.get_value(Globals.game_mode_selected, "coins_rain_reward"))
		for torch in $Torches.get_children():
			torch.set_alert(false)
		$Timers/RainRewardTimer.start()


func _on_RainSpawnTimer_timeout() -> void:
	"""
	Step 3: spawn enemies.
	"""

	var enemy := enemy_rain_scene.instance()
	enemy.position = get_random_position_spawning()
	enemy.velocity = Vector2(0, 150)
	$Rain.add_child(enemy)


func _on_RainStopTimer_timeout() -> void:
	"""
	Step 4: stop rain and alert.
	"""

	$Timers/RainSpawnTimer.stop()
	$Control/Warning/ColorRect/WarningAnimation.play("alert_off")


func _on_RainRewardTimer_timeout() -> void:
	"""
	Step 6: spawn patterns.
	"""

	# Reset timers
	$Control/Warning/Label.hide()
	$Timers/RainStartTimer.start()
	$Timers/BonusTimer.paused = false
	# Yayyyy!
	Stats.rains_dodged += 1
	# Spawn patterns
	game_state = "pattern"
	if game_pattern:
		add_random_pattern()

# Coins

func _on_Coin_caught() -> void:
	score += 1
	Stats.coins_caught += 1
	$Control/ScoreContainer/ValueScore.text = str(score)
	call_deferred("add_coins", game_coin)
	# Game mode dependent
	if Globals.game_mode_selected == "GAME_MODE_WTF":
		score_max = int(max(score_max, score))
		$Control/ScoreContainer/ValueScoreMax.text = str(score_max)


func _on_CoinBonus_caught() -> void:
	score += 1
	Stats.bonus_coins_caught += 1
	$Control/ScoreContainer/ValueScore.text = str(score)
	# Game mode dependent
	if Globals.game_mode_selected == "GAME_MODE_WTF":
		score_max = int(max(score_max, score))
		$Control/ScoreContainer/ValueScoreMax.text = str(score_max)


func _on_Coin_fall_in_lava() -> void:
	score = int(max(0, score - 1))
	Stats.coins_lost += 1
	$Control/ScoreContainer/ValueScore.text = str(score)
	# Spawn a coin if count <= 1 because queue_free() takes some time
	if $Coins.get_child_count() <= 1:
		call_deferred("add_coins", 1)


func _on_CoinBonus_fall_in_lava() -> void:
	Stats.bonus_coins_lost += 1


func add_coins(n: int):
	# Create coins at random positions
	for i in range(n):
		var coin = coin_scene.instance()
		coin.init(get_random_position_spawning())
		coin.connect("caught", self, "_on_Coin_caught")
		coin.connect("fall_in_lava", self, "_on_Coin_fall_in_lava")
		$Coins.add_child(coin)


func add_bonus_coins(n: int) -> void:
	for i in range(n):
		# Get x and y position
		var coords := get_random_position_spawning()
		# Create coin
		var coin = coin_bonus_scene.instance()
		coin.init(coords)
		coin.connect("caught", self, "_on_CoinBonus_caught")
		coin.connect("fall_in_lava", self, "_on_CoinBonus_fall_in_lava")
		$Bonus.add_child(coin)

# Bonus

func _on_BonusTimer_timeout() -> void:
	var bonus := bonus_scene.instance()
	var coords := get_random_position_spawning()
	bonus.init(coords)
	bonus.connect("caught", self, "_on_Bonus_caught")
	bonus.connect("fall_in_lava", self, "_on_Bonus_fall_in_lava")
	$Bonus.add_child(bonus)


func _on_Bonus_caught() -> void:
	Stats.bonus_caught += 1
	call_deferred("add_bonus_coins", Globals.parameters.get_value(Globals.game_mode_selected, "coins_bonus"))


func _on_Bonus_fall_in_lava() -> void:
	Stats.bonus_lost += 1

# Lava

func _on_LavaDetector_body_entered(body: Node) -> void:
	$Player.touch_lava()

# Game

func on_death() -> void:
	Stats.duration_msec = OS.get_ticks_msec() - game_start_time - game_pause_time_total
	$Player.invulnerability = true
	match Globals.game_mode_selected:
		"GAME_MODE_WTF":
			Globals.score = score_max
		_:
			Globals.score = score

	next_scene = "res://src/actors/GameOver.tscn"
	$Control/FadeTransition.fade_in()

# Misc

func load_game_mode() -> void:
	var mode = Globals.game_mode_selected

	game_coin = Globals.parameters.get_value(mode, "game_coin")
	game_pattern = Globals.parameters.get_value(mode, "game_pattern")
	game_rain = Globals.parameters.get_value(mode, "game_rain")
	game_bonus = Globals.parameters.get_value(mode, "game_bonus")

	if mode == "GAME_MODE_NORMAL":
		$Control/ScoreContainer/ValueScoreMax.hide()
		# Set timers
		$Timers/BonusTimer.wait_time = Globals.parameters.get_value(mode, "timer_bonus")
		$Timers/RainStartTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_start")
		$Timers/RainSpawnTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_dt")
		$Timers/RainStopTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_stop")
		$Timers/RainRewardTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_reward")
	elif mode == "GAME_MODE_WTF":
		$Control/ScoreContainer/ValueScoreMax.show()
	elif mode == "GAME_MODE_RAIN":
		$Control/ScoreContainer/ValueScoreMax.hide()
		# Set timers
		$Timers/RainStartTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_start")
		$Timers/RainSpawnTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_dt")
		$Timers/RainStopTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_stop")
		$Timers/RainRewardTimer.wait_time = Globals.parameters.get_value(mode, "timer_rain_reward")


func set_all_physics_process(state: bool) -> void:
	# Player
	$Player.set_physics_process(state)
	# Coins
	for coin in $Coins.get_children():
		coin.set_physics_process(state)
	# Bonus
	for bonus in $Bonus.get_children():
		bonus.set_physics_process(state)
	# Pattern
	for enemy in $Pattern.get_children():
		enemy.set_physics_process(state)
	# Rain
	for enemy in $Rain.get_children():
		enemy.set_physics_process(state)


func get_random_position_spawning() -> Vector2:
	var w :int= Globals.parameters.get_value("VIEWPORT", "width")
	var cell :int= Globals.parameters.get_value("VIEWPORT", "cell_size")
	var x := round(rand_range(cell + 8, w - cell - 8))
	var y := round(rand_range(-8, -64))
	return Vector2(x, y)
