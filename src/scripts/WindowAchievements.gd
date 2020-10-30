extends Control


onready var line_scene := preload("res://src/actors/WindowAchievementsLine.tscn")


func add_line(title: String, description: String, reward: int, done: bool) -> void:
	var line = line_scene.instance()
	line.set_labels(title, description, reward)
	line.set_done(done)
	$Scroll/VBox.add_child(line)
