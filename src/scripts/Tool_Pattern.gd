extends Node2D

const path_res := "res://assets/files/patterns.json"


func _ready() -> void:
	get_tree().paused = true
	print("Processing patterns...")
	var patterns := Array()
	for i in $Patterns.get_child_count():
		if not $Patterns.get_child(i).visible:
			continue
		print("Pattern: ", $Patterns.get_child(i).name)
		print("\t", $Patterns.get_child(i).get_child_count(), " enemies")
		var pattern := Array()
		for j in $Patterns.get_child(i).get_child_count():
			var e = $Patterns.get_child(i).get_child(j)
			pattern.append({
				"position": [e.global_position.x, e.global_position.y],
				"velocity": [e.velocity.x, e.velocity.y]
			})
		patterns.append(pattern)
	print("Done!")

	var fid := File.new()
	fid.open(path_res, fid.WRITE)
	fid.store_line(JSON.print(patterns, "\t"))
	fid.close()
	get_tree().paused = false


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_ReloadButton_pressed() -> void:
	get_tree().reload_current_scene()
