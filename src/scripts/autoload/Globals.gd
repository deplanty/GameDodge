extends Node


# Paths
const path_enemy_patterns := "res://assets/files/patterns.json"

# Previous scene
var previous_scene := String()
var previous_scene_button := bool()
var previous_scene_skip := bool()

# Mode
var game_mode_selected := "GAME_MODE_NORMAL"

# Variables
var score := 0
var pattern_velocity_multiplier := 1.0
var rain_velocity_multiplier := 1.0
onready var enemy_patterns := load_enemy_patterns()
var tileset_name := String()
var tileset :Resource

# Tileset

func set_tileset(name: String) -> void:
	tileset_name = name
	tileset = load("res://assets/images/tilesets/%s.tres" % tileset_name)

# Enemy pattern

func load_enemy_patterns() -> Array:
	var file = File.new()
	file.open(path_enemy_patterns, file.READ)
	var enemy_patterns = JSON.parse(file.get_as_text()).result
	file.close()

	return enemy_patterns
