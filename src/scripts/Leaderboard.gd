extends Control


var font_normal := load("res://assets/font/Overpass-Regular_18.tres")
var font_big := load("res://assets/font/Overpass-Bold_24.tres")
var next_scene := String()


func _ready() -> void:
	if MusicController.current_track != "menu":
		MusicController.set_track_menu("menu")
	set_highscores()
	$FadeTransition.fade_out()
	$Buttons/HBoxContainer/MainMenuButton.grab_focus()
	# Set the previous button
	if Globals.previous_scene_button:
		$BackButton.show()
	else:
		$BackButton.hide()
	# Set fonts on buttons
	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_normal)
	$TabContainer/Buttons/TabNormal/UnderlineNormal.hide()
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_normal)
	$TabContainer/Buttons/TabWTF/UnderlineWTF.hide()
	$TabContainer/Buttons/TabRain.set("custom_fonts/font", font_normal)
	$TabContainer/Buttons/TabRain/UnderlineRain.hide()
	# Show current mode leaderboard
	match Globals.game_mode_selected:
		"GAME_MODE_NORMAL":
			_on_TabNormal_pressed()
		"GAME_MODE_WTF":
			_on_TabWTF_pressed()
		"GAME_MODE_RAIN":
			_on_TabRain_pressed()

# Signals

func _on_TabNormal_pressed() -> void:
	"""
	Show the Normal mode leaderboard.
	"""

	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_big)
	$TabContainer/GAME_MODE_NORMAL.show()
	$TabContainer/Buttons/TabNormal/UnderlineNormal.show()
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_WTF.hide()
	$TabContainer/Buttons/TabWTF/UnderlineWTF.hide()
	$TabContainer/Buttons/TabRain.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_RAIN.hide()
	$TabContainer/Buttons/TabRain/UnderlineRain.hide()


func _on_TabWTF_pressed() -> void:
	"""
	Show the WTF mode leaderboard.
	"""

	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_NORMAL.hide()
	$TabContainer/Buttons/TabNormal/UnderlineNormal.hide()
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_big)
	$TabContainer/GAME_MODE_WTF.show()
	$TabContainer/Buttons/TabWTF/UnderlineWTF.show()
	$TabContainer/Buttons/TabRain.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_RAIN.hide()
	$TabContainer/Buttons/TabRain/UnderlineRain.hide()


func _on_TabRain_pressed() -> void:
	"""
	Show the Rain mode leaderboard.
	"""

	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_NORMAL.hide()
	$TabContainer/Buttons/TabNormal/UnderlineNormal.hide()
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_WTF.hide()
	$TabContainer/Buttons/TabWTF/UnderlineWTF.hide()
	$TabContainer/Buttons/TabRain.set("custom_fonts/font", font_big)
	$TabContainer/GAME_MODE_RAIN.show()
	$TabContainer/Buttons/TabRain/UnderlineRain.show()


func _on_BackButton_pressed() -> void:
	next_scene = Globals.previous_scene
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/MainMenu.tscn"
	Globals.previous_scene_skip = false
	$FadeTransition.fade_in()


func _on_ResetButton_pressed() -> void:
	$PopupConfirmReset.show()


func _on_YesButton_pressed() -> void:
	Globals.init_highscore(true)
	set_highscores()
	$PopupConfirmReset.hide()


func _on_NoButton_pressed() -> void:
	$PopupConfirmReset.hide()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		Globals.previous_scene_button = false
		Globals.previous_scene = get_tree().current_scene.filename
		get_tree().change_scene(next_scene)

# Tools

func set_highscores() -> void:
	var data = Globals.load_highscores()
	for mode in ["GAME_MODE_NORMAL", "GAME_MODE_WTF", "GAME_MODE_RAIN"]:
		for i in data[mode].size():
			var si := str(i + 1)
			get_node("TabContainer/"+mode+"/Grid/Name"+si).text = data[mode][i][0]
			get_node("TabContainer/"+mode+"/Grid/Score"+si).text = str(data[mode][i][1])
