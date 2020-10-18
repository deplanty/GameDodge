extends Node


# Paths
const path_game_parameters_res := "res://assets/game_parameters.ini"
const path_settings_res := "res://assets/user_settings.ini"
const path_settings_user := "user://user_settings.ini"
const path_highscore_res := "res://assets/highscore.json"
const path_highscore_user := "user://highscore.json"
const path_enemy_patterns := "res://assets/patterns.json"

# Mode
var mode_selected := "GAME_MODE_NORMAL"

# Settings
var parameters := ConfigFile.new()
var settings := ConfigFile.new()
var username := String()
var music_on := bool()
var sound_fx := bool()

# Variables
var score := 0
var velocity_multiplier := 1.0
var enemy_patterns := Array()


func _ready() -> void:
	# Write user files
	init_highscore()
	init_settings()
	# Load settings and parameters
	parameters.load(path_game_parameters_res)
	settings.load(path_settings_user)
	username = settings.get_value("user", "name", "")
	music_on = settings.get_value("settings", "music", true)
	sound_fx = settings.get_value("settings", "sound_fx", true)
	# Set sounds according to settings
	set_music(music_on)
	set_sound_fx(sound_fx)
	# Load enemy patterns
	load_enemy_patterns()
	# Set language
	TranslationServer.set_locale(settings.get_value("settings", "language", "en"))

# Settings

func init_settings(force: bool=false) -> void:
	"""
	If the setiings does not exist, copy the file to the user location.
	Force the replacement of the current settings if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_settings_user) and not force:
		return
	else:
		dir.copy(path_settings_res, path_settings_user)


func save_settings() -> void:
	settings.set_value("user", "name", username)
	settings.set_value("settings", "music", music_on)
	settings.set_value("settings", "sound_fx", sound_fx)
	settings.set_value("settings", "language", TranslationServer.get_locale())
	settings.save(path_settings_user)

# Highscore

func init_highscore(force: bool=false) -> void:
	"""
	If the highscore does not exist, copy the file to the user location.
	Force the replacement of the current highscore if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_highscore_user) and not force:
		return
	else:
		dir.copy(path_highscore_res, path_highscore_user)


func load_highscores() -> Dictionary:
	var file := File.new()
	file.open(path_highscore_user, file.READ)
	var data := JSON.parse(file.get_as_text())
	file.close()

	return data.result


func save_highscores(dict: Dictionary) -> void:
	var file = File.new()
	file.open(path_highscore_user, file.WRITE)
	file.store_line(JSON.print(dict, "\t"))
	file.close()

# Enemy pattern

func load_enemy_patterns() -> void:
	var file = File.new()
	file.open(path_enemy_patterns, file.READ)
	enemy_patterns = JSON.parse(file.get_as_text()).result
	file.close()

# Music

func set_music(on: bool) -> void:
	music_on = on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not on)

func set_sound_fx(on: bool) -> void:
	sound_fx = on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), not on)
