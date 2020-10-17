extends Control


var time_position := float()

var current_track := String()
var music_menu := load("res://assets/sounds/dirtyjewbs-menuloop.wav")
var music_menu_volume := -2
var music_game := load("res://assets/sounds/rolemu-LaCalahorra.ogg")
var music_game_volume := -15


func set_track_menu(menu):
	"""
	menu = [mainmenu, game]
	"""
	
	current_track = menu
	match menu:
		"mainmenu":
			$AudioStreamPlayer.stream = music_menu
			set_volume(music_menu_volume)
		"game":
			$AudioStreamPlayer.stream = music_game
			set_volume(music_game_volume)
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
