extends Node2D

# Variables

onready var coin_scene := preload("res://src/actors/Coin.tscn")
onready var enemy_scene := preload("res://src/actors/Enemy.tscn")
var score := 0
var current_enemies := []
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
	
	if all_deleted:
		get_node("/root/Globals").velocity_multiplier += 0.02
		add_random_pattern()

# Signals

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump_left"):
		$Player.jump_left()
	elif event.is_action_pressed("jump_right"):
		$Player.jump_right()
	elif event.is_action_released("pause"):
		pause_game()


func _on_TouchLeft_pressed() -> void:
	$Player.jump_left()


func _on_TouchRight_pressed() -> void:
	$Player.jump_right()


func _on_Player_first_jump() -> void:
	# Hide instructions
	$Control/Instruction.visible = false
	# Create enemies
	get_node("/root/Globals").velocity_multiplier = 1.0
	add_random_pattern()
	# Create coin
	var coin = coin_scene.instance()
	coin.init(192, -8)
	coin.connect("caught", self, "_on_Coin_caught")
	coin.connect("fall_in_lava", self, "_on_Coin_fall_in_lava")
	$Coins.add_child(coin)
	# Start game
	set_process(true)


func _on_LavaDetector_body_entered(body: Node) -> void:
	$Player.touch_lava()


func _on_Coin_caught() -> void:
	score += 1
	$Control/ScoreContainer/ValueScore/.text = str(score)
	call_deferred("add_coin")


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
		get_tree().paused = false
		get_tree().change_scene(next_scene)


func _on_PauseButton_pressed() -> void:
	pause_game()


func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	$PauseMenu.hide()


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_MainMenuButton_pressed() -> void:
	get_tree().paused = false
	$PauseMenu.hide()
	next_scene = "res://src/actors/MainMenu.tscn"
	$Control/FadeTransition.fade_in()

# Player

func on_death() -> void:
	$Player.invulnerability = true
	$"/root/Globals".score = score
	next_scene = "res://src/actors/GameOver.tscn"
	$Control/FadeTransition.fade_in()

# Patterns

func add_random_pattern() -> void:
	"""
	Add a random pattern on the scene
	"""
	
	print("Enemy speed multiplier: ", get_node("/root/Globals").velocity_multiplier)
	var i = round(rand_range(0, get_node("/root/Globals").enemy_patterns.size() - 1))
	current_enemies = load_pattern(get_node("/root/Globals").enemy_patterns, i)
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
		e.velocity = v * get_node("/root/Globals").velocity_multiplier
		array.append(e)
	
	return array

# Coin

func add_coin() -> void:
	var coin = coin_scene.instance()
	coin.init(round(rand_range(40, 360)), -8)
	coin.connect("caught", self, "_on_Coin_caught")
	coin.connect("fall_in_lava", self, "_on_Coin_fall_in_lava")
	$Coins.add_child(coin)

# UI

func pause_game() -> void:
	get_tree().paused = true
	$PauseMenu.show()
	$PauseMenu/MarginContainer/VBoxContainer/ResumeButton.grab_focus()
