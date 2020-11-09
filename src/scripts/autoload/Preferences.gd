extends Node

const path_res := "res://assets/files/preferences.ini"
const path_user := "user://preferences.ini"
var _cfg := ConfigFile.new()

# Functions

func init(force: bool=false) -> void:
	"""
	If the setiings does not exist, copy the file to the user location.
	Force the replacement of the current settings if needed.
	"""

	# Load res preferences
	_cfg.load(path_res)

	var dir := Directory.new()
	if dir.file_exists(path_user) and not force:
		# Load user preferences
		var cfg_user := ConfigFile.new()
		cfg_user.load(path_user)
		# Set user preferences in res preferences
		_cfg = Globals.merge_config_file(_cfg, cfg_user)
	else:
		dir.copy(path_res, path_user)

# ConfigFile functions

func save() -> void:
	_cfg.save(path_user)


func get_value(section: String, key: String, default=null):
	return _cfg.get_value(section, key, default)


func set_value(section: String, key: String, value):
	_cfg.set_value(section, key, value)
	save()
