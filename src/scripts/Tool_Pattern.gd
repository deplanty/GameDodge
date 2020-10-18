extends Node2D


func _ready() -> void:
	print("Processing patterns...")
	var patterns := Array()
	for i in $Patterns.get_child_count():
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
	fid.open("res://assets/patterns.json", fid.WRITE)
	fid.store_line(JSON.print(patterns, "\t"))
	fid.close()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
