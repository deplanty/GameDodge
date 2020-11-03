extends Control


var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color
	# Add achievements on screen
	for achievement in Achievements.get_all():
		var title :String= achievement
		var description :String= "%s_DESC" % achievement
		var reward :int= Achievements.get_value(achievement, "reward")
		var done :bool= Achievements.get_value(achievement, "done")
		$WindowAchievements.add_line(title, description, reward, done)

	# Show screen
	$FadeTransition.fade_out()


func _on_BackButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)
