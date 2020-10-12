extends Node


# Paths
const path_highscore_res := "res://assets/highscore.json"
const path_highscore_user := "user://highscore.json"
const path_enemy_patterns := "res://assets/patterns.json"

# Variables
var score := 0
var velocity_multiplier := 1.0
var enemy_patterns := Array()

# Options
var mode_selected := "GAME_MODE_NORMAL"


func _ready() -> void:
	# Write user files
	init_highscore(true)
	load_enemy_patterns()
	# Set language
	TranslationServer.set_locale("fr")

# Highscore

func init_highscore(force: bool=false) -> void:
	"""
	If the highscore does not exist copy the file to the user location.
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
