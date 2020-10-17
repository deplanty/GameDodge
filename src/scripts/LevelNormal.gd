extends LevelBase


onready var enemy_rain_scene := preload("res://src/actors/EnemyRain.tscn")
onready var bonus_scene := preload("res://src/actors/Bonus.tscn")
onready var coin_bonus_scene := preload("res://src/actors/CoinBonus.tscn")

# Ready

func _ready() -> void:
	._ready()
	
	# Timers
	$Timers/BonusTimer.wait_time = Globals.parameters.get_value("level_normal", "timer_bonus")
	$Timers/RainTimerStart.wait_time = Globals.parameters.get_value("level_normal", "timer_rain_start")
	$Timers/RainTimerDt.wait_time = Globals.parameters.get_value("level_normal", "timer_rain_dt")
	$Timers/RainTimerStop.wait_time = Globals.parameters.get_value("level_normal", "timer_rain_stop")
	$Timers/RainRewardTimer.wait_time = Globals.parameters.get_value("level_normal", "timer_rain_reward")


func _process(delta: float) -> void:
	._process(delta)

# Signals

func _on_Player_first_jump() -> void:
	._on_Player_first_jump()
	$Timers/BonusTimer.start()
	$Timers/RainTimerStart.start()


func _on_PauseButton_pressed() -> void:
	._on_PauseButton_pressed()
	set_bonus_physics_process(false)
	$Timers/BonusTimer.paused = true
	$Timers/RainTimerDt.paused = true
	$Timers/RainTimerStart.paused = true


func _on_BonusTimer_timeout() -> void:
	var bonus := bonus_scene.instance()
	var coords := get_random_position_spawning()
	bonus.init(coords)
	bonus.connect("caught", self, "_on_Bonus_caught")
	$Bonus.add_child(bonus)


func _on_Bonus_caught() -> void:
	call_deferred("add_bonus_coin", Globals.parameters.get_value("level_normal", "coins_bonus"))


func _on_RainTimerStart_timeout() -> void:
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
		for torch in $World/Torches.get_children():
			torch.set_alert(true)
		$Timers/RainTimerDt.start()
		$Timers/RainTimerStop.start()
	elif anim_name == "calm":
		add_bonus_coin(Globals.parameters.get_value("level_normal", "coins_rain_reward"))
		for torch in $World/Torches.get_children():
			torch.set_alert(false)
		$Timers/RainRewardTimer.start()


func _on_RainTimerDt_timeout() -> void:
	var enemy := enemy_rain_scene.instance()
	enemy.position = get_random_position_spawning()
	enemy.velocity = Vector2(0, 150)
	$EnemyRain.add_child(enemy)


func _on_RainTimerStop_timeout() -> void:
	$Timers/RainTimerDt.stop()
	$Control/Warning/ColorRect/WarningAnimation.play("calm")


func _on_RainRewardTimer_timeout() -> void:
	$Control/Warning/Label.visible = false
	$Timers/RainTimerStart.start()
	$Timers/BonusTimer.paused = false
	game_state = "pattern"

# Game

func on_resume_game() -> void:
	.on_resume_game()
	set_bonus_physics_process(true)
	$Timers/RainTimerStart.paused = false
	$Timers/RainTimerDt.paused = false
	if game_state == "pattern":
		$Timers/BonusTimer.paused = false

# Coins

func add_bonus_coin(n: int) -> void:
	for i in range(n):
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
