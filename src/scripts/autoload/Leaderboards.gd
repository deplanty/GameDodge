extends Node

const path_res := "res://assets/highscore.json"
const path_user := "user://highscore.json"
var _data := Dictionary()


func init(force: bool=false) -> void:
	"""
	If the highscore does not exist, copy the file to the user location.
	Force the replacement of the current highscore if needed.
	"""

	var dir := Directory.new()
	if dir.file_exists(path_user) and not force:
		pass
	else:
		dir.copy(path_res, path_user)

	_data = load_data()


func _custom_sort(a, b):
	return a[1] > b[1]


func add_entry(game_mode: String, name: String, score: int):
	var highscores = _data[game_mode]
	# Add current score and sort them
	highscores.append([name, score])
	highscores.sort_custom(self, "_custom_sort")
	highscores.pop_back()
	# Write highscores
	_data[game_mode] = highscores
	save()

# Getter

func get_all() -> Dictionary:
	return _data

func get_leaderboard(game_mode:String) -> Array:
	return _data[game_mode]

# Json functions

func load_data() -> Dictionary:
	var file := File.new()
	file.open(path_user, file.READ)
	var data := JSON.parse(file.get_as_text())
	file.close()

	return data.result


func save() -> void:
	var file = File.new()
	file.open(path_user, file.WRITE)
	file.store_line(JSON.print(_data, "\t"))
	file.close()
