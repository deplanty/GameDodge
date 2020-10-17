extends Control


var next_scene := String()


func _ready() -> void:
	# Set menu music
	if MusicController.current_track != "mainmenu":
		MusicController.set_track_menu("mainmenu")
	# Set Interface
	$FadeTransition.fade_out()
	$PlayButton.grab_focus()
	$SwitchModeButton.set_label("BUTTON_MODE_LABEL")
	$SwitchModeButton.set_list(["GAME_MODE_NORMAL", "GAME_MODE_WTF"], Globals.mode_selected)
	# Set player animation
	$Player.first_move = true
	$Player.velocity.x = -$Player.speed.x
	$Player.look_left()

# Signals

func _on_OptionButton_pressed() -> void:
	next_scene = "res://src/actors/Settings.tscn"
	$FadeTransition.fade_in()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_PlayButton_pressed() -> void:
#	Globals.mode_selected = $SwitchModeButton.get_selection()
	match Globals.mode_selected:
		"GAME_MODE_NORMAL":
			next_scene = "res://src/actors/LevelNormal.tscn"
		"GAME_MODE_WTF":
			next_scene = "res://src/actors/LevelWTF.tscn"
	$FadeTransition.fade_in()


func _on_SwitchModeButton_selection_changed() -> void:
	Globals.mode_selected = $SwitchModeButton.get_selection()


func _on_HighscoreButton_pressed() -> void:
	next_scene = "res://src/actors/Leaderboard.tscn"
	$FadeTransition.fade_in()


func _on_Area2D_body_entered(body: Node) -> void:
	$Player.jump()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	"""
	Change scene after the fade transition
	"""
	
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)
