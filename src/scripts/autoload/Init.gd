extends Node


func _ready() -> void:
	Preferences.init()
	MusicController.init()
	Achievements.init()
	Leaderboards.init()
	Shop.init()

	# Set language
	TranslationServer.set_locale(Preferences.get_value("settings", "language"))

	# Set theme
	var world_skin = Preferences.get_value("shop", "world_skin")
	Globals.set_world_skin(world_skin)
	Skins.load_skin(world_skin)

	var player_skin = Preferences.get_value("shop", "player_skin")
	Globals.set_player(player_skin)

	var game_mode = Preferences.get_value("shop", "game_mode")
	Globals.game_mode_selected = "GAME_MODE_" + game_mode.to_upper()
