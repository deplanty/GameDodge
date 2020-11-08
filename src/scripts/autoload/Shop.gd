extends Node


const path_res := "res://assets/files/shop.ini"
const path_user := "user://shop.ini"
var _cfg := ConfigFile.new()

var coins := int() setget set_coins, get_coins

# Functions

func init(force: bool=false) -> void:
	"""
	If the shop does not exist, copy the file to the user location.
	Force the replacement of the current shop if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_user) and not force:
		pass
	else:
		dir.copy(path_res, path_user)

	_cfg.load(path_user)


func buy(section: String, item: String) -> void:
	var price = _cfg.get_value(section, item)
	var money = get_coins()
	money -= price

	if money < 0:
		push_error("Coins in inventory cannot be negative.")
		return

	set_coins(money)
	set_value(section, item, 0)


func is_bought(section: String, item: String) -> bool:
	# An item is bought if its price is 0
	return _cfg.get_value(section, item) == 0


# Getters

func get_world_skins() ->  PoolStringArray:
	return _cfg.get_section_keys("WORLD_SKIN")


func get_section_keys(section: String) -> PoolStringArray:
	return _cfg.get_section_keys(section)


func get_coins() -> int:
	return _cfg.get_value("INVENTORY", "coins")


func set_coins(value: int):
	_cfg.set_value("INVENTORY", "coins", value)
	save()


# ConfigFile functions

func save() -> void:
	_cfg.save(path_user)


func get_value(section: String, key: String, default=null):
	return _cfg.get_value(section, key, default)


func set_value(section: String, key: String, value):
	_cfg.set_value(section, key, value)
	save()
