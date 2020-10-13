extends Control

# Music
var img_music_on := load("res://assets/images/ui/music_on.png")
var img_music_off := load("res://assets/images/ui/music_off.png")
# Effects
var img_sound_fx := load("res://assets/images/ui/sound_fx_on.png")
var img_fx_off := load("res://assets/images/ui/sound_fx_off.png")


func _ready() -> void:
	print(Globals.music_on)
	if Globals.music_on:
		$Container/VBox/Sound/MusicButton.icon = img_music_on
	else:
		$Container/VBox/Sound/MusicButton.icon = img_music_off
		
	if Globals.sound_fx:
		$Container/VBox/Sound/EffectsButton.icon = img_sound_fx
	else:
		$Container/VBox/Sound/EffectsButton.icon = img_fx_off

# Signals

func _on_ButtonEn_pressed() -> void:
	TranslationServer.set_locale("en")
	Globals.save_settings()


func _on_ButtonFr_pressed() -> void:
	TranslationServer.set_locale("fr")
	Globals.save_settings()


func _on_MusicButton_pressed() -> void:
	if Globals.music_on:
		Globals.set_music(false)
		$Container/VBox/Sound/MusicButton.icon = img_music_off
	else:
		Globals.set_music(true)
		$Container/VBox/Sound/MusicButton.icon = img_music_on
	Globals.save_settings()


func _on_EffectsButton_pressed() -> void:
	if Globals.sound_fx:
		Globals.set_sound_fx(false)
		$Container/VBox/Sound/EffectsButton.icon = img_fx_off
	else:
		Globals.set_sound_fx(true)
		$Container/VBox/Sound/EffectsButton.icon = img_sound_fx
	Globals.save_settings()


func _on_MainMenuButton_pressed() -> void:
	get_tree().change_scene("res://src/actors/MainMenu.tscn")
