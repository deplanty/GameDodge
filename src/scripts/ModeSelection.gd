extends Control


func _ready() -> void:
	$FadeTransition.fade_out()


func _on_NormalButton_pressed() -> void:
	Globals.game_mode_selected = "GAME_MODE_NORMAL"
	$FadeTransition.fade_in()


func _on_WTFButton_pressed() -> void:
	Globals.game_mode_selected = "GAME_MODE_COINSFRENZY"
	$FadeTransition.fade_in()


func _on_RainButton_pressed() -> void:
	Globals.game_mode_selected = "GAME_MODE_RAIN"
	$FadeTransition.fade_in()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene("res://src/actors/Level.tscn")
