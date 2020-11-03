extends Node


func _ready() -> void:
	Preferences.init()
	Achievements.init()
	Leaderboards.init()
	Shop.init()
	# Set language
	TranslationServer.set_locale(Preferences.get_value("settings", "language"))

	# Initialize tileset
	Globals.set_tileset(Preferences.get_value("skins", "world"))
