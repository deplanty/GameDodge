extends LevelBase


onready var bonus_scene := preload("res://src/actors/Bonus.tscn")
onready var coin_bonus_scene := preload("res://src/actors/CoinBonus.tscn")


# Signals

func _on_Player_first_jump() -> void:
	._on_Player_first_jump()
	$Timers/BonusTimer.start()
	$Timers/EnemyRainTimerStart.start()


func _on_PauseButton_pressed() -> void:
	._on_PauseButton_pressed()
	set_bonus_physics_process(false)
	$Timers/BonusTimer.paused = true
	$Timers/RainTimer.paused = true
	$Timers/EnemyRainTimerStart.paused = true


func _on_BonusTimer_timeout() -> void:
	var bonus := bonus_scene.instance()
	var coords := get_random_position_spawning()
	bonus.init(coords)
	bonus.connect("caught", self, "_on_Bonus_caught")
	$Bonus.add_child(bonus)


func _on_Bonus_caught() -> void:
	call_deferred("add_bonus_coin")


func _on_EnemyRainTimerStart_timeout() -> void:
	"""
	Stop the bonus timer.
	TODO: Remove coins and bonus.
	Start alert animation
	"""
	
	$Timers/BonusTimer.paused = true
	
	$Control/Warning/Label.visible = true
	$Control/Warning/ColorRect/WarningAnimation.play("alert")
	game_state = "rain"


func _on_WarningAnimation_animation_finished(anim_name: String) -> void:
	if anim_name == "alert":
		$Control/Warning/Label.visible = false
		$Timers/EnemyRainTimerStart.stop()
		$Timers/RainTimer.start()
		$Timers/EnemyRainTimerStop.start()
	elif anim_name == "calm":
		$Control/Warning/Label.visible = false
		$Timers/EnemyRainTimerStart.start()
		$Timers/BonusTimer.paused = false
		game_state = "pattern"


func _on_RainTimer_timeout() -> void:
	var enemy := enemy_scene.instance()
	enemy.position = get_random_position_spawning()
	enemy.velocity = Vector2(0, 150)
	$EnemyRain.add_child(enemy)


func _on_EnemyRainTimerStop_timeout() -> void:
	$Timers/RainTimer.stop()
	$Timers/EnemyRainTimerStop.stop()
	$Control/Warning/ColorRect/WarningAnimation.play("calm")

# Game

func on_resume_game() -> void:
	.on_resume_game()
	set_bonus_physics_process(true)
	$Timers/EnemyRainTimerStart.paused = false
	$Timers/RainTimer.paused = false
	if game_state == "rain":
		$Timers/BonusTimer.paused = false

# Coins

func add_bonus_coin() -> void:
	for i in range(5):
		# Get x and y position
		var coords := get_random_position_spawning()
		# Create coin
		var coin = coin_bonus_scene.instance()
		coin.init(coords)
		coin.connect("caught", self, "_on_CoinBonus_caught")
		$Coins.add_child(coin)

# Tools

func set_bonus_physics_process(state: bool) -> void:
	for bonus in $Bonus.get_children():
		bonus.set_physics_process(state)
	for enemy in $EnemyRain.get_children():
		enemy.set_physics_process(state)
