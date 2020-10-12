"""
Explanation:
------------

At the end of the game, the score is saved globaly.
When this scene is ready, an animation with coins is played.
The amount of coins created depends on the score value.

After the animation (when the last coin is caught), it checks if it's a new
highscore.
If it's a new highscore, it makes the player jump and it shows an entry.
If it's not a highscore; it shows the buttons.
"""

extends Control


# Satisfying animation to reach the score
var coin_sum := 0  # To reach the score
onready var coin_scene := preload("res://src/actors/Coin.tscn")
# Highscore
var highscores := Dictionary()  # All mode highscores
var highscore := Array()  # Current mode highscores
onready var mode_selected = $"/root/Globals".mode_selected
var next_scene := String()

func _ready() -> void:
	$FadeTransition.fade_out()
	# Player
	$Control/Player.velocity = Vector2(0, 0)
	$Control/Player.first_move = true
	$Control/Player.set_physics_process(false)
	$Control/Player/AnimatedSprite.play("right")
	# Start animation
	$Control/SpawnTimer.start(0.1)
	# Highscore
	highscores = Globals.load_highscores()
	highscore = highscores[mode_selected]

# Signals

func _on_NameEdit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		if $Name/NameEdit.text == "":
			return
		add_highscore($Name/NameEdit.text, get_node("/root/Globals").score)
		$Name.visible = false
		$Buttons.visible = true
		$Buttons/RestartButton.grab_focus()


func _on_RestartButton_pressed() -> void:
	if Globals.mode_selected == "Normal":
		next_scene = "res://src/actors/LevelNormal.tscn"
	elif Globals.mode_selected == "WTF":
		next_scene = "res://src/actors/LevelWTF.tscn"
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	$FadeTransition.fade_in()
	next_scene = "res://src/actors/Highscore.tscn"


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_SpawnTimer_timeout() -> void:
	# If not all coins have spawned
	if coin_sum < Globals.score:
		var coin = coin_scene.instance()
		coin.init($Control/Player.position.x, $Control/Player.position.y - 100)
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
		$Control/Player.jump_mainmenu()

# Highscore

func show_after_animation() -> void:
	"""
	Show UI elements after the coins animation.
	"""
	
	# If score is a highscore
	if Globals.score > highscore[-1][1]:
		$ScoreLabel.text = "Nouveau record !"
		$Name.visible = true
		$Buttons.visible = false
		$Name/NameEdit.grab_focus()
		$Control/Player.set_physics_process(true)
	# If score is not a highscore
	else:
		$Name.visible = false
		$Buttons.visible = true
		$Buttons/RestartButton.grab_focus()
	
	$ScoreLabel.visible = true
	

func custom_highscore_sort(a, b):
	return a[1] > b[1]


func add_highscore(name: String, score: int) -> void:
	# Add current score and sort them
	highscore.append([name, score])
	highscore.sort_custom(self, "custom_highscore_sort")
	highscore.pop_back()
	# Write highscores
	highscores[mode_selected] = highscore
	get_node("/root/Globals").save_highscores(highscores)
