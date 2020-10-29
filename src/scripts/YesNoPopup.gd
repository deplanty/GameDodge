extends Popup


signal pressed_yes_no(yes)


export var message := String()


func _ready() -> void:
	$Message.text = message


func _on_YesButton_pressed() -> void:
	emit_signal("pressed_yes_no", true)


func _on_NoButton_pressed() -> void:
	emit_signal("pressed_yes_no", false)
