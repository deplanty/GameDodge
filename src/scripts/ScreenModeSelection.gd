extends Control


var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color
	$FadeTransition.fade_out()

	# TODO: Use an automatic method to display available game modes
	# Normal
	if Shop.is_bought("GAME_MODE", "normal"):
		$Scroll/HBox/NormalButton.disabled = false
	else:
		$Scroll/HBox/NormalButton.disabled = true
	# Coins Frenzy
	if Shop.is_bought("GAME_MODE", "coins_frenzy"):
		$Scroll/HBox/WTFButton.disabled = false
	else:
		$Scroll/HBox/WTFButton.disabled = true
	# Rain
	if Shop.is_bought("GAME_MODE", "rain"):
		$Scroll/HBox/RainButton.disabled = false
	else:
		$Scroll/HBox/RainButton.disabled = true


func _on_NormalButton_pressed() -> void:
	Globals.game_mode_selected = "GAME_MODE_NORMAL"
	next_scene = "res://src/actors/screens/Level.tscn"
	$FadeTransition.fade_in()


func _on_WTFButton_pressed() -> void:
	Globals.game_mode_selected = "GAME_MODE_COINSFRENZY"
	next_scene = "res://src/actors/screens/Level.tscn"
	$FadeTransition.fade_in()


func _on_RainButton_pressed() -> void:
	Globals.game_mode_selected = "GAME_MODE_RAIN"
	next_scene = "res://src/actors/screens/Level.tscn"
	$FadeTransition.fade_in()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_BackButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$FadeTransition.fade_in()
