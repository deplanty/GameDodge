extends Node


# Config file
const path_res := "res://assets/files/skins.ini"
var _cfg := ConfigFile.new()
# Parameters
var color := Color()
var accent := Color()

# Initialize

func _ready() -> void:
	_cfg.load(path_res)


func load_skin(name: String):
	color = _cfg.get_value(name, "color")
	accent = _cfg.get_value(name, "accent")
