extends Node


# Paths
const path_enemy_patterns := "res://assets/files/patterns.json"

# Previous scene
var previous_scene := String()
var previous_scene_skip := bool()

# Mode
var game_mode_selected := "GAME_MODE_NORMAL"

# Variables
var score := 0
var pattern_velocity_multiplier := 1.0
var rain_velocity_multiplier := 1.0
# Tileset
var tileset :Resource
# Player
var player :Texture
# Enemies
onready var enemy_patterns := load_enemy_patterns()
var enemy_pattern : Texture
var enemy_rain :Texture
# Skin
var world_skin := String()

# Tileset

func set_world_skin(name: String) -> void:
	world_skin = name
	tileset = load("res://assets/images/tilesets/%s.tres" % name)
	enemy_pattern = load("res://assets/images/enemies/%s_pattern.png" % name)
	enemy_rain = load("res://assets/images/enemies/%s_rain.png" % name)


func set_player(name: String) -> void:
	player = load("res://assets/images/players/%s.png" % name)

# Enemy pattern

func load_enemy_patterns() -> Array:
	var file = File.new()
	file.open(path_enemy_patterns, file.READ)
	var enemy_patterns = JSON.parse(file.get_as_text()).result
	file.close()

	return enemy_patterns

# Tools

static func merge_config_file(dst: ConfigFile, src: ConfigFile) -> ConfigFile:
	# Merge source ConfigFile into destination ConfigFile

	for section in src.get_sections():
		for key in src.get_section_keys(section):
			# Set the source value
			var src_value = src.get_value(section, key)
			dst.set_value(section, key, src_value)

	return dst

func get_random_position_spawning() -> Vector2:
	var w :int= Settings.get_value("VIEWPORT", "width")
	var cell :int= Settings.get_value("VIEWPORT", "cell_size")
	var x := round(rand_range(cell + 8, w - cell - 8))
	var y := round(rand_range(-8, -64))
	return Vector2(x, y)
