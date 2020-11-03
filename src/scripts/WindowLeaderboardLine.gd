extends Control


func _ready() -> void:
	# Set theme color
	$Border.color = Skins.accent


func set_labels(left: String, right: String) -> void:
	$Fill/LabelLeft.text = left
	$Fill/LabelRight.text = right
