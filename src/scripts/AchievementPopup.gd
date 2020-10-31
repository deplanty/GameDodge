extends Control


signal fade_out


func _ready() -> void:
	hide()


func _on_AchievementPopup_tree_entered() -> void:
	$AnimationPlayer.play("fade_in")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		$AnimationPlayer.play("show_medal")
	elif anim_name == "fade_out":
		emit_signal("fade_out")
		queue_free()


func _on_LifeTimer_timeout() -> void:
	$AnimationPlayer.play("fade_out")

# Tools

func set_labels(title: String, description: String) -> void:
	$Fill/Title.text = title
	$Fill/Description.text = description
