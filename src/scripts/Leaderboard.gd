extends Control


var font_normal := load("res://assets/font/Overpass-Regular_18.tres")
var font_big := load("res://assets/font/Overpass-Bold_24.tres")
var next_scene := String()


func _ready() -> void:
	set_highscores()
	$FadeTransition.fade_out()
	$Buttons/HBoxContainer/MainMenuButton.grab_focus()
	# Set fonts on buttons
	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_normal)
	$TabContainer/Buttons/TabNormal/UnderlineNormal.visible = false
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_normal)
	$TabContainer/Buttons/TabWTF/UnderlineWTF.visible = false
	# Show current mode leaderboard
	match Globals.mode_selected:
		"GAME_MODE_NORMAL":
			_on_TabNormal_pressed()
		"GAME_MODE_WTF":
			_on_TabWTF_pressed()

# Signals

func _on_TabNormal_pressed() -> void:
	"""
	Show the Normal mode leaderboard.
	"""
	
	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_big)
	$TabContainer/GAME_MODE_NORMAL.visible = true
	$TabContainer/Buttons/TabNormal/UnderlineNormal.visible = true
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_WTF.visible = false
	$TabContainer/Buttons/TabWTF/UnderlineWTF.visible = false


func _on_TabWTF_pressed() -> void:
	"""
	Show the WTF mode leaderboard.
	"""
	
	$TabContainer/Buttons/TabNormal.set("custom_fonts/font", font_normal)
	$TabContainer/GAME_MODE_NORMAL.visible = false
	$TabContainer/Buttons/TabNormal/UnderlineNormal.visible = false
	$TabContainer/Buttons/TabWTF.set("custom_fonts/font", font_big)
	$TabContainer/GAME_MODE_WTF.visible = true
	$TabContainer/Buttons/TabWTF/UnderlineWTF.visible = true


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/MainMenu.tscn"
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
		get_tree().change_scene(next_scene)

# Tools

func set_highscores() -> void:
	var data = Globals.load_highscores()
	for mode in ["GAME_MODE_NORMAL", "GAME_MODE_WTF"]:
		for i in data[mode].size():
			var si := str(i + 1)
			get_node("TabContainer/"+mode+"/Grid/Name"+si).text = data[mode][i][0]
			get_node("TabContainer/"+mode+"/Grid/Score"+si).text = str(data[mode][i][1])
