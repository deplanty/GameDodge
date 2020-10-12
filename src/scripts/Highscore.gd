extends Control


var next_scene := String()


func _ready() -> void:
	set_highscores()
	$FadeTransition.fade_out()
	$Buttons/HBoxContainer/MainMenuButton.grab_focus()

# Signals

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
	for mode in ["Normal", "WTF"]:
		for i in data[mode].size():
			var si := str(i + 1)
			get_node("TabContainer/"+mode+"/Grid/Name"+si).text = data[mode][i][0]
			get_node("TabContainer/"+mode+"/Grid/Score"+si).text = str(data[mode][i][1])
