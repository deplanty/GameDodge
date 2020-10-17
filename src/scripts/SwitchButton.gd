extends Button


signal selection_changed


var elements := Array()
var current := 0

# Signals

func _on_SwitchButton_pressed() -> void:
	"""
	Select next element.
	"""
	
	# Cycle
	current += 1
	if current >= elements.size():
		current = 0
	$HBoxContainer/Selection.text = elements[current]
	emit_signal("selection_changed")

# Tools

func set_label(label: String) -> void:
	$HBoxContainer/Label.text = label


func set_list(list: Array, index=0) -> void:
	"""
	Set the list and the current element.
	'current' can be an integer or an element of the list.
	"""
	
	elements.clear()
	elements = list
	
	if typeof(index) == TYPE_INT:
		current = index
	else:
		current = elements.find(index)
	$HBoxContainer/Selection.text = elements[current]


func get_selection() -> String:
	return $HBoxContainer/Selection.text
