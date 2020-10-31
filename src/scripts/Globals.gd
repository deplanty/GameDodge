extends Node


# Paths
const path_game_parameters_res := "res://assets/game_parameters.ini"
const path_settings_res := "res://assets/user_settings.ini"
const path_settings_user := "user://user_settings.ini"
const path_highscore_res := "res://assets/highscore.json"
const path_highscore_user := "user://highscore.json"
const path_shop_res := "res://assets/shop.ini"
const path_shop_user := "user://shop.ini"
const path_achievements_res := "res://assets/achievements.ini"
const path_achievements_user := "user://achievements.ini"
const path_enemy_patterns := "res://assets/patterns.json"

# Previous scene
var previous_scene := String()
var previous_scene_button := bool()
var previous_scene_skip := bool()

# Mode
var game_mode_selected := "GAME_MODE_NORMAL"

# Settings
var parameters := ConfigFile.new()
var settings := ConfigFile.new()
var shop := ConfigFile.new()
var username := String()
var music_on := bool()
var sound_fx := bool()

var tileset_name :String
var tileset :Resource

# Variables
var score := 0
var pattern_velocity_multiplier := 1.0
var rain_velocity_multiplier := 1.0
var enemy_patterns := Array()


func _ready() -> void:
	# Write user files
	init_highscore()
	init_settings()
	init_shop(true)
	init_achievements()
	# Load settings and parameters
	parameters.load(path_game_parameters_res)
	settings.load(path_settings_user)
	username = settings.get_value("user", "name", "")
	music_on = settings.get_value("settings", "music", true)
	sound_fx = settings.get_value("settings", "sound_fx", true)
	tileset_name = settings.get_value("skins", "world", "default")
	tileset = load("res://assets/images/tilesets/%s.tres" % tileset_name)
	# Load the shop and the achievements
	shop.load(path_shop_user)
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

# Shop

func init_shop(force: bool=false) -> void:
	"""
	If the shop does not exist, copy the file to the user location.
	Force the replacement of the current shop if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_shop_user) and not force:
		return
	else:
		dir.copy(path_shop_res, path_shop_user)


func save_shop() -> void:
	shop.save(path_shop_user)

# Achivements

func init_achievements(force: bool=false) -> void:
	"""
	If the achievements does not exist, copy the file to the user location.
	Force the replacement of the current achievements if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_achievements_user) and not force:
		return
	else:
		dir.copy(path_achievements_res, path_achievements_user)

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
