extends Control

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
	$Background.color = Skins.color
	# Set music
	if MusicController.track_current != "game":
		MusicController.set_track_menu("game")
	# Set player
	$Player.life = Settings.get_value(Globals.game_mode_selected, "player_life")
	$Control/Lifebar.set_max_life($Player.life)

	# Game parameters
	Globals.pattern_velocity_multiplier = 1.0
	Globals.rain_velocity_multiplier = 1.0

	# Game mode dependent
	load_game_mode()

	# Reset parameters
	Stats.reset()
	Achievements.reset()

	# Fade out to display the game
	$FadeTransition.fade_out()


func _process(delta: float) -> void:
	if $Player.first_move:
		var time_played := OS.get_ticks_msec() - game_start_time - game_pause_time_total
		var s := round(time_played / 1000)
		var m := int(s / 60)
		s = s - m * 60
		$Control/Chrono.text = "%02d:%02d" % [m, s]

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


func _on_ResumeButton_pressed() -> void:
	$PauseMenu.hide()
	$Control/ResumeCounter.text = str(resume_counter)
	$Timers/ResumeTimer.start()


func _on_RestartButton_pressed() -> void:
	next_scene = get_tree().current_scene.filename
	$ConfirmPopup.message = "LABEL_CONFIRM_RESTART"
	$ConfirmPopup.show()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$ConfirmPopup.message = "LABEL_CONFIRM_MAINMENU"
	$ConfirmPopup.show()


func _on_ConfirmPopup_pressed_yes_no(yes: bool) -> void:
	if yes:
		get_tree().paused = false
		$ConfirmPopup.hide()
		$PauseMenu.hide()
		$FadeTransition.fade_in()
	else:
		$ConfirmPopup.hide()
		$ConfirmPopup.hide()


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
	game_start_time = OS.get_ticks_msec()


func _on_Player_lose_life() -> void:
	$Control/Lifebar.set_life($Player.life)
	if $Player.life <= 0:
		on_death()

	if Achievements.first_time_hit_msec == 0:
		Achievements.first_time_hit_msec = OS.get_ticks_msec() - game_start_time
		prints("Time first hit:", Achievements.first_time_hit_msec / 1000, "s")

# Pattern

func _on_Enemy_tree_exited() -> void:
	if game_state == "pattern" and $Pattern.get_child_count() <= 0:
		Stats.patterns_dodged += 1
		add_random_pattern()


func add_random_pattern() -> void:
	"""
	Add a random pattern on the scene.
	"""

	print("Enemy speed multiplier: ", Globals.pattern_velocity_multiplier)
	var i = round(rand_range(0, Globals.enemy_patterns.size() - 1))
	current_enemies = load_pattern(Globals.enemy_patterns, i)
	for e in current_enemies:
		$Pattern.add_child(e)
	# Increase speed for next pattern
	Globals.pattern_velocity_multiplier += Settings.get_value(Globals.game_mode_selected, "pattern_velocity_increase")


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
		e.velocity = v * Globals.pattern_velocity_multiplier
		e.connect("tree_exited", self, "_on_Enemy_tree_exited")
		array.append(e)

	return array

# Rain

func _on_RainStartTimer_timeout() -> void:
	"""
	Step 1: Prepare rain and show warning.

	Stop the bonus timer.
	Start alert animation
	"""

	if game_bonus:
		$Timers/BonusTimer.paused = true

	$Control/Warning/Label.show()
	$Control/Warning/ColorRect/WarningAnimation.play("alert_on")
	game_state = "rain"

	print("Rain speed multiplier: ", Globals.rain_velocity_multiplier)


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
		add_bonus_coins(Settings.get_value(Globals.game_mode_selected, "coins_rain_reward"))
		for torch in $Torches.get_children():
			torch.set_alert(false)
		$Timers/RainRewardTimer.start()


func _on_RainSpawnTimer_timeout() -> void:
	"""
	Step 3: spawn enemies.
	"""

	var enemy := enemy_rain_scene.instance()
	enemy.position = Globals.get_random_position_spawning()
	enemy.velocity = Vector2(0, 150) * Globals.rain_velocity_multiplier
	$Rain.add_child(enemy)


func _on_RainStopTimer_timeout() -> void:
	"""
	Step 4: stop rain and alert.
	"""

	$Timers/RainSpawnTimer.stop()
	$Control/Warning/ColorRect/WarningAnimation.play("alert_off")
	Globals.rain_velocity_multiplier += Settings.get_value(Globals.game_mode_selected, "rain_velocity_increase")
	$Timers/RainSpawnTimer.wait_time /= Settings.get_value(Globals.game_mode_selected, "rain_density_increase")


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
	if Globals.game_mode_selected == "GAME_MODE_COINSFRENZY":
		score_max = int(max(score_max, score))
		$Control/ScoreContainer/ValueScoreMax.text = str(score_max)
	# Achievements
	Achievements.only_coins_bonus = 0


func _on_CoinBonus_caught() -> void:
	score += 1
	Stats.bonus_coins_caught += 1
	$Control/ScoreContainer/ValueScore.text = str(score)
	# Game mode dependent
	if Globals.game_mode_selected == "GAME_MODE_COINSFRENZY":
		score_max = int(max(score_max, score))
		$Control/ScoreContainer/ValueScoreMax.text = str(score_max)
	# Achievements
	Achievements.only_coins_bonus += 1
	Achievements.only_coins_bonus_max = max(
		Achievements.only_coins_bonus,
		Achievements.only_coins_bonus_max
	)


func _on_Coin_fall_in_lava() -> void:
	# Punish on coin fall in lava
	print(Globals.game_mode_selected)
	if Globals.game_mode_selected == "GAME_MODE_COINSFRENZY":
		score = int(max(0, score - 1))
		$Control/ScoreContainer/ValueScore.text = str(score)
	Stats.coins_lost += 1
	# Spawn a coin if count <= 1 because queue_free() takes some time
	if $Coins.get_child_count() <= 1:
		call_deferred("add_coins", 1)


func _on_CoinBonus_fall_in_lava() -> void:
	Stats.bonus_coins_lost += 1


func add_coins(n: int):
	# Create coins at random positions
	for i in range(n):
		var coin = coin_scene.instance()
		coin.init(Globals.get_random_position_spawning())
		coin.connect("caught", self, "_on_Coin_caught")
		coin.connect("fall_in_lava", self, "_on_Coin_fall_in_lava")
		$Coins.add_child(coin)


func add_bonus_coins(n: int) -> void:
	for i in range(n):
		# Get x and y position
		var coords := Globals.get_random_position_spawning()
		# Create coin
		var coin = coin_bonus_scene.instance()
		coin.init(coords)
		coin.connect("caught", self, "_on_CoinBonus_caught")
		coin.connect("fall_in_lava", self, "_on_CoinBonus_fall_in_lava")
		$Bonus.add_child(coin)

# Bonus

func _on_BonusTimer_timeout() -> void:
	var bonus := bonus_scene.instance()
	var coords := Globals.get_random_position_spawning()
	bonus.init(coords)
	bonus.connect("caught", self, "_on_Bonus_caught")
	bonus.connect("fall_in_lava", self, "_on_Bonus_fall_in_lava")
	$Bonus.add_child(bonus)


func _on_Bonus_caught() -> void:
	Stats.bonus_caught += 1
	call_deferred("add_bonus_coins", Settings.get_value(Globals.game_mode_selected, "coins_bonus"))


func _on_Bonus_fall_in_lava() -> void:
	Stats.bonus_lost += 1

# Lava

func _on_LavaDetector_body_entered(body: Node) -> void:
	if body == $Player:
		$Player.touch_lava()
	elif typeof(body) == typeof(enemy_scene):
		body.queue_free()

# Game

func on_death() -> void:
	Stats.duration_msec = OS.get_ticks_msec() - game_start_time - game_pause_time_total
	$Player.invulnerability = true
	match Globals.game_mode_selected:
		"GAME_MODE_COINSFRENZY":
			Globals.score = score_max
		_:
			Globals.score = score
	# Store coins in the inventory
	var total_coins = Shop.get_value("INVENTORY", "coins")
	Shop.set_value("INVENTORY", "coins", total_coins + Globals.score)

	next_scene = "res://src/actors/screens/GameOver.tscn"
	$FadeTransition.fade_in()

# Misc

func load_game_mode() -> void:
	var mode = Globals.game_mode_selected

	game_coin = Settings.get_value(mode, "game_coin")
	game_pattern = Settings.get_value(mode, "game_pattern")
	game_rain = Settings.get_value(mode, "game_rain")
	game_bonus = Settings.get_value(mode, "game_bonus")

	if mode == "GAME_MODE_NORMAL":
		$Control/ScoreContainer/ValueScoreMax.hide()
		# Set timers
		$Timers/BonusTimer.wait_time = Settings.get_value(mode, "timer_bonus")
		$Timers/RainStartTimer.wait_time = Settings.get_value(mode, "timer_rain_start")
		$Timers/RainSpawnTimer.wait_time = Settings.get_value(mode, "timer_rain_dt")
		$Timers/RainStopTimer.wait_time = Settings.get_value(mode, "timer_rain_stop")
		$Timers/RainRewardTimer.wait_time = Settings.get_value(mode, "timer_rain_reward")
	elif mode == "GAME_MODE_COINSFRENZY":
		$Control/ScoreContainer/ValueScoreMax.show()
	elif mode == "GAME_MODE_RAIN":
		$Control/ScoreContainer/ValueScoreMax.hide()
		# Set timers
		$Timers/RainStartTimer.wait_time = Settings.get_value(mode, "timer_rain_start")
		$Timers/RainSpawnTimer.wait_time = Settings.get_value(mode, "timer_rain_dt")
		$Timers/RainStopTimer.wait_time = Settings.get_value(mode, "timer_rain_stop")
		$Timers/RainRewardTimer.wait_time = Settings.get_value(mode, "timer_rain_reward")
