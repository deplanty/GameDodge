extends Control


var next_scene := String()


func _ready() -> void:
	if not MusicController.playing():
		MusicController.set_track("res://assets/sounds/rolemu-LaCalahorra.ogg", true)
		MusicController.set_volume(-15)
	$FadeTransition.fade_out()
	$PlayButton.grab_focus()
	$SwitchModeButton.set_label("BUTTON_MODE_LABEL")
	$SwitchModeButton.set_list(["GAME_MODE_NORMAL", "GAME_MODE_WTF"], Globals.mode_selected)
	
	$Player.first_move = true
	$Player.velocity.x = -$Player.speed.x

# Signals

func _on_OptionButton_pressed() -> void:
	next_scene = "res://src/actors/Settings.tscn"
	$FadeTransition.fade_in()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_PlayButton_pressed() -> void:
	var mode_selected = $SwitchModeButton.get_selection()
	Globals.mode_selected = mode_selected
	if mode_selected == "GAME_MODE_NORMAL":
		next_scene = "res://src/actors/LevelNormal.tscn"
	elif mode_selected == "GAME_MODE_WTF":
		next_scene = "res://src/actors/LevelWTF.tscn"
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	next_scene = "res://src/actors/Leaderboard.tscn"
	$FadeTransition.fade_in()


func _on_Area2D_body_entered(body: Node) -> void:
	$Player.jump_mainmenu()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	"""
	Change scene after the fade transition
	"""
	
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)
