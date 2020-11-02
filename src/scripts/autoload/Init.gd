extends Node


func _ready() -> void:
	SettingsUser.init()
	Achievements.init()
	Leaderboards.init()
	Shop.init()
	# Set language
	TranslationServer.set_locale(SettingsUser.get_value("settings", "language"))

	# Initialize tileset
	Globals.set_tileset(SettingsUser.get_value("skins", "world"))
