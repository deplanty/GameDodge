extends Node


var _cfg := ConfigFile.new()

# Achievements variables

var first_time_hit_msec := 0
var only_coins_bonus := true

# Functions

func _ready() -> void:
	_cfg.load(Globals.path_achievements_user)

# Tools

func reset() -> void:
	first_time_hit_msec = 0
	only_coins_bonus = true


func validate(section: String):
	_cfg.set_value(section, "done", true)
	save()

# ConfigFile functions

func save() -> void:
	_cfg.save(Globals.path_achievements_user)


func get_value(section: String, key: String, default=null):
	return _cfg.get_value(section, key, default)
