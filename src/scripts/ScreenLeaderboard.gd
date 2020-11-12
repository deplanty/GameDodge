extends Control


var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color

	if MusicController.track_current != "menu":
		MusicController.set_track_menu("menu")
	set_highscores()

	$FadeTransition.fade_out()

# Signals

func _on_BackButton_pressed() -> void:
	next_scene = Globals.previous_scene
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	Globals.previous_scene_skip = false
	$FadeTransition.fade_in()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
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
