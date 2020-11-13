extends Popup


signal pressed_yes_no(yes)


export var message := String() setget set_message, get_message


func _ready() -> void:
	$Message.text = message


func _on_YesButton_pressed() -> void:
	emit_signal("pressed_yes_no", true)


func _on_NoButton_pressed() -> void:
	emit_signal("pressed_yes_no", false)

# setget

func set_message(new_message: String) -> void:
	message = new_message
	$Message.text = message


func get_message() -> String:
	return message
