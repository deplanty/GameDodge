extends Node


var _cfg := ConfigFile.new()

# Achievements variables

var first_time_hit_msec := 0
var only_coins_bonus := 0
var only_coins_bonus_max := 0

# Functions

func _ready() -> void:
	_cfg.load(Globals.path_achievements_user)


func get_all() -> Array:
	var all := Array()
	for family in _cfg.get_value("FAMILIES", "all"):
		var index := 1
		var section := "%s_%d" % [family, index]
		while _cfg.has_section(section):
			all.push_back(section)
			index += 1
			section = "%s_%d" % [family, index]

	return all


func check_all() -> Array:
	# Returns an array of all the completed achievements
	var done := Array()
	for family in _cfg.get_value("FAMILIES", "all"):
		var section = check_family(family)
		if section:
			done.push_back(section)

	return done


func check_family(section_name: String) -> String:
	var index := 1
	var section := "%s_%d" % [section_name, index]

	# Check for all the sections of the achivement family
	while _cfg.has_section(section):
		# If achievement is done, continue to next
		if _cfg.get_value(section, "done"):
			index += 1
			section = "%s_%d" % [section_name, index]
			continue

		# Check if section is ok
		if check_section(section):
			completed(section)
			return section

		index += 1
		section = "%s_%d" % [section_name, index]

	return ""


func check_section(section) -> bool:
	# Check if the game mode is valid
	if _cfg.get_value(section, "game_mode") != Globals.game_mode_selected:
		return false

	# Check which variable is used
	var variable = INF
	match _cfg.get_value(section, "variable"):
		"coins_bonus":
			variable = only_coins_bonus_max
		"first_hit":
			variable = first_time_hit_msec / 1000  # convert to secs

	# Check if completed
	if variable >= get_value(section, "threshold"):
		return true
	else:
		return false

# Tools

func reset() -> void:
	first_time_hit_msec = 0
	only_coins_bonus = true


func completed(section: String):
	# Save updated achievement
	_cfg.set_value(section, "done", true)
	save()
	# Store reward coins in the inventory
	var total_coins = Globals.shop.get_value("INVENTORY", "coins")
	Globals.shop.set_value("INVENTORY", "coins", total_coins + _cfg.get_value(section, "reward"))
	Globals.save_shop()

# ConfigFile functions

func save() -> void:
	_cfg.save(Globals.path_achievements_user)


func get_value(section: String, key: String, default=null):
	return _cfg.get_value(section, key, default)
