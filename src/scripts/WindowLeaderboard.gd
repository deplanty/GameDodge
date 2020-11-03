extends Control


func _ready() -> void:
	# Set theme color
	$Border.color = Skins.accent
	$BorderTitle.color = Skins.accent


func set_title(title: String) -> void:
	$Title/Label.text = title


func set_array(array: Array) -> void:
	for i in array.size():
		set_line(i, array[i][0], array[i][1])


func set_line(row: int, name: String, value: int) -> void:
	var line = $Scores/Lines.get_child(row)
	line.set_labels(name, str(value))
