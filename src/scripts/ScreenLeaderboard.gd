extends Control


var next_scene := String()


func _ready() -> void:
	if MusicController.track_current != "menu":
		MusicController.set_track_menu("menu")
	set_highscores()
	$FadeTransition.fade_out()
	$Buttons/HBoxContainer/MainMenuButton.grab_focus()
	# Set the previous button
	if Globals.previous_scene_button:
		$BackButton.show()
	else:
		$BackButton.hide()

# Signals

func _on_BackButton_pressed() -> void:
	next_scene = Globals.previous_scene
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	Globals.previous_scene_skip = false
	$FadeTransition.fade_in()


func _on_ResetButton_pressed() -> void:
	$PopupConfirmReset.show()


func _on_YesNoPopup_pressed_yes_no(yes) -> void:
	if yes:
		Leaderboards.init(true)
		set_highscores()

	$PopupConfirmReset.hide()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		Globals.previous_scene_button = false
		Globals.previous_scene = get_tree().current_scene.filename
		get_tree().change_scene(next_scene)

# Tools

func set_highscores() -> void:
	var data = Leaderboards.get_all()
	$Scores/HBox/Normal.set_title("GAME_MODE_NORMAL")
	$Scores/HBox/Normal.set_array(data["GAME_MODE_NORMAL"])
	$Scores/HBox/CoinsFrenzy.set_title("GAME_MODE_COINSFRENZY")
	$Scores/HBox/CoinsFrenzy.set_array(data["GAME_MODE_COINSFRENZY"])
	$Scores/HBox/Rain.set_title("GAME_MODE_RAIN")
	$Scores/HBox/Rain.set_array(data["GAME_MODE_RAIN"])
