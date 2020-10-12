extends Control


var next_scene := String()
var img_tick := load("res://assets/images/ui/tick.png")
var img_cross := load("res://assets/images/ui/cross.png")


func _ready() -> void:
	if not MusicController.playing():
		MusicController.set_track("res://assets/sounds/rolemu-LaCalahorra.ogg", true)
		MusicController.set_volume(-15)
	$FadeTransition.fade_out()
	$PlayButton.grab_focus()
	$SwitchModeButton.set_label("Mode :")
	$SwitchModeButton.set_list(["Normal", "WTF"], Globals.mode_selected)
	
	$Player.first_move = true
	$Player.velocity.x = -$Player.speed.x


func _on_PlayButton_pressed() -> void:
	var mode_selected = $SwitchModeButton.get_selection()
	Globals.mode_selected = mode_selected
	if mode_selected == "Normal":
		next_scene = "res://src/actors/LevelNormal.tscn"
	elif mode_selected == "WTF":
		next_scene = "res://src/actors/LevelWTF.tscn"
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	next_scene = "res://src/actors/Highscore.tscn"
	$FadeTransition.fade_in()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_Area2D_body_entered(body: Node) -> void:
	$Player.jump_mainmenu()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	"""
	Change scene after the fade transition
	"""
	
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)
