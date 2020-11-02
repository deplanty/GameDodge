extends Control


var next_scene := String()


func _ready() -> void:
	# Set menu music
	if MusicController.track_current != "menu":
		MusicController.set_track_menu("menu")
	# Set Interface
	$FadeTransition.fade_out()
	$PlayButton.grab_focus()
	# Set player animation
	$Player.first_move = true
	$Player.velocity.x = -$Player.speed.x
	$Player.look_left()

	print("Total coins: ", Shop.get_value("INVENTORY", "coins"))

# Signals

func _on_OptionButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Settings.tscn"
	$FadeTransition.fade_in()


func _on_QuitButton_pressed() -> void:
	$QuitPopup.show()


func _on_PlayButton_pressed() -> void:
	next_scene = "res://src/actors/screens/ModeSelection.tscn"
	$FadeTransition.fade_in()


func _on_AchievementsButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Achievements.tscn"
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Leaderboard.tscn"
	$FadeTransition.fade_in()


func _on_ShopButton_pressed() -> void:
	next_scene = "res://src/actors/screens/Shop.tscn"
	$FadeTransition.fade_in()


func _on_QuitPopup_pressed_yes_no(yes: bool) -> void:
	if yes:
		next_scene = "quit"
		$FadeTransition.fade_in()

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
