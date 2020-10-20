"""
Explanation:
------------

At the end of the game, the score is saved globaly.
When this scene is ready, an animation with coins is played.
The amount of coins created depends on the score value.
If the score is 0, it shows the buttons.

After the animation (when the last coin is caught), it checks if it's a new
highscore.
If it's a new highscore, it makes the player jump and it shows an entry.
If it's not a highscore; it shows the buttons.
"""

extends Control


# Satisfying animation to reach the score
var coin_sum := 0  # To reach the score
export var coin_spawn_dt := 0.1  # To spawn coins
onready var coin_scene := preload("res://src/actors/Coin.tscn")
# Highscore
var highscores := Dictionary()  # All mode highscores
var highscore := Array()  # Current mode highscores
onready var game_mode_selected = Globals.game_mode_selected
var next_scene := String()


func _ready() -> void:
	# Load highscore
	highscores = Globals.load_highscores()
	highscore = highscores[game_mode_selected]
	# Player
	$Control/Player.velocity = Vector2(0, 0)
	$Control/Player.first_move = true
	$Control/Player.set_physics_process(false)
	$Control/Player.look_right()
	# Start animation
	if Globals.score > 0:
		$Control/SpawnTimer.start(coin_spawn_dt )
	else:
		show_after_animation()

	$FadeTransition.fade_out()

	print("Patterns esquivés : ", Stats.patterns_dodged)
	print("Pluies évitées : ", Stats.rain_dodged)
	print("Pièces attrapées : ", Stats.coins_caught)
	print("Pièces perdues : ", Stats.coins_lost)
	print("Pièces bonus attrapées : ", Stats.bonus_coins_caught)
	print("Bonus attrapés : ", Stats.bonus_caught)
	print("Pièces bonus perdues : ", Stats.bonus_coins_lost)
	print("Bonus perdus : ", Stats.bonus_lost)

# Signals

func _on_SkipAnimationButton_pressed() -> void:
	$SkipAnimationButton.hide()
	for coin in $Control/Coins.get_children():
		coin.queue_free()
	$Control/SpawnTimer.stop()
	$ScoreValue.text = str(Globals.score)
	show_after_animation()


func _on_NameEdit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		_on_NameButton_pressed()


func _on_NameButton_pressed() -> void:
	if $Name/NameEdit.text == "":
		return
	$Name.hide()
	$Buttons.show()
	$Buttons/RestartButton.grab_focus()
	# Save higscore and player name
	add_highscore($Name/NameEdit.text, Globals.score)
	Globals.username = $Name/NameEdit.text
	Globals.save_settings()


func _on_RestartButton_pressed() -> void:
	next_scene = "res://src/actors/Level.tscn"
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	$FadeTransition.fade_in()
	next_scene = "res://src/actors/Leaderboard.tscn"


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_SpawnTimer_timeout() -> void:
	# If not all coins have spawned
	if coin_sum < Globals.score:
		var coin = coin_scene.instance()
		var coords = $Control/Player.position
		coords.y -= 100
		coin.init(coords)
		# If last coin
		if coin_sum == Globals.score - 1:
			coin.connect("caught", self, "_on_Coin_caught_last")
		else:
			coin.connect("caught", self, "_on_Coin_caught")
		coin.get_node("AnimationPlayer").play("fade_in")
		$Control/Coins.add_child(coin)
		coin_sum += 1
	# Lase coin
	else:
		$Control/SpawnTimer.stop()


func _on_Coin_caught() -> void:
	$ScoreValue.text = str(coin_sum)


func _on_Coin_caught_last() -> void:
	_on_Coin_caught()
	show_after_animation()


func _on_AreaJump_body_entered(body: Node) -> void:
	if body == $Control/Player:
		$Control/Player.jump()

# Highscore

func show_after_animation() -> void:
	"""
	Show UI elements after the coins animation.
	"""

	# If score is a highscore
	if Globals.score > highscore[-1][1]:
		$ScoreLabel.text = "TITLE_NEW_HIGHSCORE"
		$Name.show()
		$Buttons.hide()
		$Name/NameEdit.text = Globals.username
		$Name/NameEdit.grab_focus()
		$Control/Player.set_physics_process(true)
	# If score is not a highscore
	else:
		$ScoreLabel.text = "TITLE_SCORE"
		$Name.hide()
		$Buttons.show()
		$Buttons/RestartButton.grab_focus()

	$ScoreLabel.show()


func custom_highscore_sort(a, b):
	return a[1] > b[1]


func add_highscore(name: String, score: int) -> void:
	# Add current score and sort them
	highscore.append([name, score])
	highscore.sort_custom(self, "custom_highscore_sort")
	highscore.pop_back()
	# Write highscores
	highscores[game_mode_selected] = highscore
	Globals.save_highscores(highscores)
