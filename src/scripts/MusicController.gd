extends Control


var time_position := float()

var current_track := String()
onready var tracks := load_tracks()


func set_track_menu(menu):
	"""
	menu = [menu, game]
	"""
	
	current_track = menu
	var track = tracks[menu]
	$AudioStreamPlayer.stream = track[0]
	set_volume(track[1])
	time_position = 0
	play()


func set_track(track_url: String, load_and_play: bool=false) -> void:
	current_track = track_url
	time_position = 0
	$AudioStreamPlayer.stream = load(track_url)
	if load_and_play:
		play()


func play() -> void:
	$AudioStreamPlayer.play(time_position)


func pause() -> void:
	time_position = $AudioStreamPlayer.get_playback_position()
	stop()


func stop() -> void:
	time_position = 0.0
	$AudioStreamPlayer.stop()


func set_volume(dB: float=0.0):
	$AudioStreamPlayer.volume_db = dB

# Properties

func playing() -> bool:
	return $AudioStreamPlayer.playing

# Import

func load_track_menu(menu: String) -> Array:
	var track = Globals.parameters.get_value("music", menu)
	var track_url = "res://assets/sounds/%s" % track
	var volume = Globals.parameters.get_value("music", "%s_volume" % menu)
	return [load(track_url), volume]


func load_tracks() -> Dictionary:
	var tracks := Dictionary()
	tracks["menu"] = load_track_menu("menu")
	tracks["game"] = load_track_menu("game")
	return tracks
