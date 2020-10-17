extends Node2D
class_name LevelBase

# Variables

onready var coin_scene := preload("res://src/actors/Coin.tscn")
onready var enemy_scene := preload("res://src/actors/Enemy.tscn")
var score := 0
var resume_counter := 3
var current_enemies := []
var game_paused := false
var game_state := "pattern"
var next_scene := String()

# Porcess

func _ready() -> void:
	print("New game")
	$Control/FadeTransition.fade_out()
	# Wait for user to jump once in ordre to start the scene
	set_process(false)


func _process(delta: float) -> void:
	# Check if all the enemies are deleted
	var all_deleted = true
	for e in current_enemies:
		if is_instance_valid(e):
			all_deleted = false
			break
	
	if all_deleted and game_state == "pattern":
		Globals.velocity_multiplier += Globals.parameters.get_value("gameplay", "velocity_multiplier")
		add_random_pattern()

# Signals

func _input(event: InputEvent) -> void:
	if not game_paused:
		if event.is_action_pressed("jump_left"):
			$Player.jump_left()
		elif event.is_action_pressed("jump_right"):
			$Player.jump_right()
		elif event.is_action_released("pause"):
			_on_PauseButton_pressed()


func _on_TouchLeft_pressed() -> void:
	print("TouchLeft")
	$Player.jump_left()


func _on_TouchRight_pressed() -> void:
	print("TouchRight")
	$Player.jump_right()


func _on_Player_first_jump() -> void:
	# Hide instructions
	$Control/Instruction.visible = false
	# Create enemies
	Globals.velocity_multiplier = 1.0
	add_random_pattern()
	# Create coin
	add_coin()
	# Start game
	set_process(true)


func _on_LavaDetector_body_entered(body: Node) -> void:
	$Player.touch_lava()


func _on_Coin_caught() -> void:
	score += 1
	$Control/ScoreContainer/ValueScore/.text = str(score)
	call_deferred("add_coin")


func _on_CoinBonus_caught() -> void:
	score += 1
	$Control/ScoreContainer/ValueScore/.text = str(score)


func _on_Coin_fall_in_lava() -> void:
	score = int(max(0, score - 1))
	$Control/ScoreContainer/ValueScore/.text = str(score)
	call_deferred("add_coin")


func _on_Player_lose_life() -> void:
	$Control/Lifebar.set_life($Player.life)
	if $Player.life <= 0:
		on_death()


func _on_FadeTransition_animation_finished(anim_name) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_PauseButton_pressed() -> void:
	game_paused = true
	set_all_physics_process(false)
	$PauseMenu.show()
	$PauseMenu/MarginContainer/VBoxContainer/ResumeButton.grab_focus()


func _on_ResumeButton_pressed() -> void:
	$PauseMenu.hide()
	$Control/ResumeCounter.text = str(resume_counter)
	$Control/ResumeCounter/ResumeTimer.start()


func _on_RestartButton_pressed() -> void:
	$PauseMenu.hide()
	get_tree().reload_current_scene()


func _on_MainMenuButton_pressed() -> void:
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
		on_resume_game()

# Game

func on_resume_game() -> void:
	game_paused = false
	resume_counter = 3
	$Control/ResumeCounter/ResumeTimer.stop()
	set_all_physics_process(true)

# Player

func on_death() -> void:
	$Player.invulnerability = true
	Globals.score = score
	next_scene = "res://src/actors/GameOver.tscn"
	$Control/FadeTransition.fade_in()

# Patterns

func add_random_pattern() -> void:
	"""
	Add a random pattern on the scene
	"""
	
	print("Enemy speed multiplier: ", Globals.velocity_multiplier)
	var i = round(rand_range(0, Globals.enemy_patterns.size() - 1))
	current_enemies = load_pattern(Globals.enemy_patterns, i)
	for e in current_enemies:
		$Enemies.add_child(e)


func load_pattern(patterns, i: int) -> Array:
	"""
	Load a single pattern
	"""
	
	var array = []
	for enemy in patterns[i]:
		var p = Vector2(enemy["position"][0], enemy["position"][1])
		var v = Vector2(enemy["velocity"][0], enemy["velocity"][1])
		var e = enemy_scene.instance()
		e.position = p
		e.velocity = v * Globals.velocity_multiplier
		array.append(e)
	
	return array

# Coin

func add_coin():
	# Get x and y position
	# Create coin
	var coin = coin_scene.instance()
	coin.init(get_random_position_spawning())
	coin.connect("caught", self, "_on_Coin_caught")
	coin.connect("fall_in_lava", self, "_on_Coin_fall_in_lava")
	$Coins.add_child(coin)

# UI

func set_all_physics_process(state: bool) -> void:
	$Player.set_physics_process(state)
	for coin in $Coins.get_children():
		coin.set_physics_process(state)
	for enemy in $Enemies.get_children():
		enemy.set_physics_process(state)

# Misc

func get_random_position_spawning() -> Vector2:
	var w :int= Globals.parameters.get_value("viewport", "width")
	var cell :int= Globals.parameters.get_value("viewport", "cell_size")
	var x := round(rand_range(cell + 8, w - cell - 8))
	var y := round(rand_range(-8, -64))
	return Vector2(x, y)
