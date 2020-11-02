extends Control


# Tracks
var track_position := float()
var track_current := String()
onready var tracks := load_tracks()
# Parameters
var music_on := bool() setget set_music, is_music_on
var sound_fx_on := bool() setget set_sound_fx, is_sound_fx_on


func _ready() -> void:
	set_music(SettingsUser.get_value("settings", "music"))
	set_sound_fx(SettingsUser.get_value("settings", "sound_fx"))

# Functions

func set_track_menu(menu):
	"""
	menu = [menu, game]
	"""

	track_current = menu
	var track = tracks[menu]
	$AudioStreamPlayer.stream = track[0]
	set_volume(track[1])
	track_position = 0
	play()


func set_track(track_url: String, load_and_play: bool=false) -> void:
	track_current = track_url
	track_position = 0
	$AudioStreamPlayer.stream = load(track_url)
	if load_and_play:
		play()


func play() -> void:
	$AudioStreamPlayer.play(track_position)


func pause() -> void:
	track_position = $AudioStreamPlayer.get_playback_position()
	$AudioStreamPlayer.stop()


func stop() -> void:
	track_position = 0.0
	$AudioStreamPlayer.stop()


func set_volume(dB: float=0.0):
	$AudioStreamPlayer.volume_db = dB

# Tools

func set_music(on: bool=true) -> void:
	music_on = on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not on)


func is_music_on() -> bool:
	return music_on


func set_sound_fx(on: bool=true) -> void:
	sound_fx_on = on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), not on)


func is_sound_fx_on() -> bool:
	return sound_fx_on

# Import

func load_track_menu(menu: String) -> Array:
	var track = Settings.get_value("MUSIC", menu)
	var track_url = "res://assets/sounds/%s" % track
	var volume = Settings.get_value("MUSIC", "%s_volume" % menu)
	return [load(track_url), volume]


func load_tracks() -> Dictionary:
	var tracks := Dictionary()
	tracks["menu"] = load_track_menu("menu")
	tracks["game"] = load_track_menu("game")
	return tracks
