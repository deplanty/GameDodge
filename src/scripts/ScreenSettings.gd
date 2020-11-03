extends Control

# Music
var img_music_on := load("res://assets/images/ui/music_on.png")
var img_music_off := load("res://assets/images/ui/music_off.png")
# Effects
var img_sound_fx := load("res://assets/images/ui/sound_fx_on.png")
var img_fx_off := load("res://assets/images/ui/sound_fx_off.png")

var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color

	if MusicController.track_current != "menu":
		MusicController.set_track_menu("menu")

	if MusicController.is_music_on():
		$Container/VBox/Sound/MusicButton.icon = img_music_on
	else:
		$Container/VBox/Sound/MusicButton.icon = img_music_off

	if MusicController.is_sound_fx_on():
		$Container/VBox/Sound/EffectsButton.icon = img_sound_fx
	else:
		$Container/VBox/Sound/EffectsButton.icon = img_fx_off

	$FadeTransition.fade_out()

# Signals

func _on_ButtonEn_pressed() -> void:
	TranslationServer.set_locale("en")
	Preferences.set_value("settings", "language", "en")


func _on_ButtonFr_pressed() -> void:
	TranslationServer.set_locale("fr")
	Preferences.set_value("settings", "language", "fr")


func _on_MusicButton_pressed() -> void:
	if MusicController.is_music_on():
		$Container/VBox/Sound/MusicButton.icon = img_music_off
		MusicController.set_music(false)
		Preferences.set_value("settings", "music", false)
	else:
		$Container/VBox/Sound/MusicButton.icon = img_music_on
		MusicController.set_music(true)
		Preferences.set_value("settings", "music", true)


func _on_EffectsButton_pressed() -> void:
	if MusicController.is_sound_fx_on():
		$Container/VBox/Sound/EffectsButton.icon = img_fx_off
		MusicController.set_sound_fx(false)
		Preferences.set_value("settings", "sound_fx", false)
	else:
		$Container/VBox/Sound/EffectsButton.icon = img_sound_fx
		MusicController.set_sound_fx(true)
		Preferences.set_value("settings", "sound_fx", true)


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)
