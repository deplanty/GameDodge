extends Node


const path_res := "res://assets/game_parameters.ini"
var _cfg := ConfigFile.new()


func _ready() -> void:
	_cfg.load(path_res)

# ConfigFile functions

func get_value(section: String, key: String, default=null):
	return _cfg.get_value(section, key, default)
