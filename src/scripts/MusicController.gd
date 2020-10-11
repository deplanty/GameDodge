extends Control


var time_position := float()


func set_track(track_url: String, load_and_play: bool=false) -> void:
	$AudioStreamPlayer.stream = load(track_url)
	if load_and_play:
		play()


func play() -> void:
	$AudioStreamPlayer.play(time_position)


func pause() -> void:
	time_position = $AudioStreamPlayer.get_playback_position()
	stop()


func stop() -> void:
	$AudioStreamPlayer.stop()


func set_volume(dB: float=0):
	$AudioStreamPlayer.volume_db = dB

# Properties

func playing() -> bool:
	return $AudioStreamPlayer.playing
