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
# Achievements
var achievement_popup_scene := preload("res://src/actors/popups/AchievementPopup.tscn")
var achievements_completed := Array()
var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color
	# Load stats
	set_stats()
	# Player
	$Control/Player.velocity = Vector2(0, 0)
	$Control/Player.first_move = true
	$Control/Player.set_physics_process(false)
	$Control/Player.look_right()
	# Start animation
	if Globals.score > 0 and not Globals.previous_scene_skip:
		$Control/SpawnTimer.start(coin_spawn_dt )
	else:
		show_after_animation()
		_on_SkipAnimationButton_pressed()

	# Check for achievements
	achievements_completed = Achievements.check_all()

	$FadeTransition.fade_out()

# Signals

func _on_SkipAnimationButton_pressed() -> void:
	$SkipAnimationButton.hide()
	for coin in $Control/Coins.get_children():
		coin.queue_free()
	$Control/SpawnTimer.stop()
	$ScoreValue.text = str(Globals.score)
	show_after_animation()


func _on_StatsToggleButton_pressed() -> void:
	$StatsPopup.show()


func _on_PopupCloseButton_pressed() -> void:
	$StatsPopup.hide()


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
	Leaderboards.add_entry(Globals.game_mode_selected, $Name/NameEdit.text, Globals.score)
	Preferences.set_value("user", "name", $Name/NameEdit.text)


func _on_RestartButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Level.tscn"
	Globals.previous_scene_skip = false
	Globals.previous_scene_button = false
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	Globals.previous_scene_skip = false
	Globals.previous_scene_button = false
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	$FadeTransition.fade_in()
	Globals.previous_scene_skip = true
	Globals.previous_scene_button = true
	next_scene = "res://src/actors/screens/Leaderboard.tscn"


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		Globals.previous_scene = get_tree().current_scene.filename
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

# Show

func show_after_animation() -> void:
	"""
	Show UI elements after the coins animation.
	"""

	var leaderboard = Leaderboards.get_leaderboard(Globals.game_mode_selected)

	# If score is a highscore (at least superior than the lowest)
	if Globals.score > leaderboard[-1][1]:
		$ScoreLabel.text = "TITLE_NEW_HIGHSCORE"
		$Name.show()
		$Buttons.hide()
		$Name/NameEdit.text = Preferences.get_value("user", "name")
		$Name/NameEdit.grab_focus()
		$Control/Player.set_physics_process(true)
	# If score is not a highscore
	else:
		$ScoreLabel.text = "TITLE_SCORE"
		$Name.hide()
		$Buttons.show()
		$Buttons/RestartButton.grab_focus()

	# If we come back from the leaderboard
	if Globals.previous_scene_skip:
		$Name.hide()
		$Buttons.show()
		$Buttons/RestartButton.grab_focus()

	# Show achievements
	show_achievements()

	$ScoreLabel.show()


func show_achievements():
	# Show the achievements one after another
	for achievement in achievements_completed:
		var title :String= achievement
		var description :String= "%s_DESC" % achievement
		var line := achievement_popup_scene.instance()
		line.set_labels(title, description)
		$Achievements.add_child(line)
		yield(line, "fade_out")

# Statistics

func set_stats() -> void:
	# Game duration
	var s := round(Stats.duration_msec / 1000)
	var m := int(s / 60)
	s = s - m * 60
	add_stats_line("LABEL_STATS_DURATION", "%02d:%02d" % [m, s])
	# Dodges
	add_stats_line("", "")
	if Settings.get_value(Globals.game_mode_selected, "game_pattern"):
		add_stats_line("LABEL_STATS_PATTERNS_DODGED", Stats.patterns_dodged)
	if Settings.get_value(Globals.game_mode_selected, "game_rain"):
		add_stats_line("LABEL_STATS_RAINS_DODGED", Stats.rains_dodged)
	# Coins
	add_stats_line("", "")
	add_stats_line("LABEL_STATS_COINS_CAUGHT", Stats.coins_caught)
	add_stats_line("LABEL_STATS_COINS_LOST", Stats.coins_lost)
	add_stats_line("LABEL_STATS_COINS_BONUS_CAUGHT", Stats.bonus_coins_caught)
	add_stats_line("LABEL_STATS_COINS_BONUS_LOST", Stats.bonus_coins_lost)
	if Settings.get_value(Globals.game_mode_selected, "game_bonus"):
		add_stats_line("LABEL_STATS_BONUS_CAUGHT", Stats.bonus_caught)
		add_stats_line("LABEL_STATS_BONUS_LOST", Stats.bonus_lost)

	# If at least one coin or bonus have been lost
	if Stats.coins_lost + Stats.bonus_coins_lost + Stats.bonus_lost > 0:
		var total := Stats.coins_caught + Stats.coins_lost
		total += Stats.bonus_coins_caught + Stats.bonus_coins_lost
		total += Stats.bonus_lost * Settings.get_value(Globals.game_mode_selected, "coins_bonus", 0)
		add_stats_line("", "")
		add_stats_line("LABEL_STATS_TAUNT", total, true)


func add_stats_line(text: String, value, autowrap: bool=false) -> void:
	var label = Label.new()
	label.text = text
	label.autowrap = autowrap
	label.rect_min_size.x = 170
	$StatsPopup/Container/Grid.add_child(label)

	var label_value = Label.new()
	label_value.text = str(value)
	$StatsPopup/Container/Grid.add_child(label_value)
