extends Button


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

# Tools

func set_label(label: String) -> void:
	$HBoxContainer/Label.text = label


func set_list(list: Array, current=0) -> void:
	"""
	Set the list and the current element.
	'current' can be an integer or an element of the list.
	"""
	
	elements.clear()
	elements = list
	
	if typeof(current) == TYPE_INT:
		current = current
	else:
		current = elements.find(current)
	
	$HBoxContainer/Selection.text = elements[current]


func get_selection() -> String:
	return $HBoxContainer/Selection.text
