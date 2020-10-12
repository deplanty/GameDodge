extends Control

# Music
var img_music_on := load("res://assets/images/ui/music_on.png")
var img_music_off := load("res://assets/images/ui/music_off.png")
# Effects
var img_fx_on := load("res://assets/images/ui/sound_effects_on.png")
var img_fx_off := load("res://assets/images/ui/sound_effects_off.png")


func _ready() -> void:
	if Globals.music_on:
		$Container/VBox/Sound/MusicButton.icon = img_music_on
	else:
		$Container/VBox/Sound/MusicButton.icon = img_music_off
		
	if Globals.fx_on:
		$Container/VBox/Sound/EffectsButton.icon = img_fx_on
	else:
		$Container/VBox/Sound/EffectsButton.icon = img_fx_off

# Signals

func _on_ButtonEn_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_ButtonFr_pressed() -> void:
	TranslationServer.set_locale("fr")


func _on_MainMenuButton_pressed() -> void:
	get_tree().change_scene("res://src/actors/MainMenu.tscn")


func _on_MusicButton_pressed() -> void:
	if Globals.music_on == true:
		Globals.music_on = false
		$Container/VBox/Sound/MusicButton.icon = img_music_off
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		Globals.music_on = true
		$Container/VBox/Sound/MusicButton.icon = img_music_on
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)


func _on_EffectsButton_pressed() -> void:
	if Globals.fx_on == true:
		Globals.fx_on = false
		$Container/VBox/Sound/EffectsButton.icon = img_fx_off
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), true)
	else:
		Globals.fx_on = true
		$Container/VBox/Sound/EffectsButton.icon = img_fx_on
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), false)
