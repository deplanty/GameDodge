extends Control


var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color
	# Set menu music
	if MusicController.track_current != "menu":
		MusicController.set_track_menu("menu")
	# Set player animation
	$Player.first_move = true
	$Player.velocity.x = -$Player.speed.x
	$Player.look_left()
	# Set Interface
	$HBox/GameMode.text = Globals.game_mode_selected
	$FadeTransition.fade_out()

# User events

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump_left"):
		$Player.jump_left()
	elif event.is_action_pressed("jump_right"):
		$Player.jump_right()


func _on_TouchLeft_pressed() -> void:
	$Player.jump_left()


func _on_TouchRight_pressed() -> void:
	$Player.jump_right()

# Signals

func _on_OptionButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Settings.tscn"
	$FadeTransition.fade_in()


func _on_QuitButton_pressed() -> void:
	$QuitPopup.show()
	$TouchLeft.hide()
	$TouchRight.hide()


func _on_PlayButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Level.tscn"
	$FadeTransition.fade_in()


func _on_AchievementsButton_pressed() -> void:
	Globals.previous_scene = get_tree().current_scene.filename
	next_scene = "res://src/actors/screens/Achievements.tscn"
	$Coin.disconnect("caught", self, "_on_Coin_caught")
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	Globals.previous_scene = get_tree().current_scene.filename
	next_scene = "res://src/actors/screens/Leaderboard.tscn"
	$Coin.disconnect("caught", self, "_on_Coin_caught")
	$FadeTransition.fade_in()


func _on_ShopButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Shop.tscn"
	$Coin.disconnect("caught", self, "_on_Coin_caught")
	$FadeTransition.fade_in()


func _on_QuitPopup_pressed_yes_no(yes: bool) -> void:
	if yes:
		next_scene = "quit"
		$FadeTransition.fade_in()
	else:
		$TouchLeft.show()
		$TouchRight.show()

	$QuitPopup.hide()


func _on_Area2D_body_entered(body: Node) -> void:
	$Player.jump()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	"""
	Change scene after the fade transition
	"""

	if anim_name == "fade_in":
		if next_scene == "quit":
			get_tree().quit()
		else:
			get_tree().change_scene(next_scene)


func _on_Coin_caught() -> void:
	_on_PlayButton_pressed()
