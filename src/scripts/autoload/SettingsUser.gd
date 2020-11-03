extends Node

const path_res := "res://assets/files/user_settings.ini"
const path_user := "user://user_settings.ini"
var _cfg := ConfigFile.new()

# Functions

func init(force: bool=false) -> void:
	"""
	If the setiings does not exist, copy the file to the user location.
	Force the replacement of the current settings if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_user) and not force:
		pass
	else:
		dir.copy(path_res, path_user)

	_cfg.load(path_user)

# ConfigFile functions

func save() -> void:
	_cfg.save(path_user)


func get_value(section: String, key: String, default=null):
	return _cfg.get_value(section, key, default)


func set_value(section: String, key: String, value):
	_cfg.set_value(section, key, value)
	save()
