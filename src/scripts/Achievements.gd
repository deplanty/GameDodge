extends Control


var next_scene := String()


func _ready() -> void:
	$FadeTransition.fade_out()


func _on_BackButton_pressed() -> void:
	next_scene = "res://src/actors/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)
