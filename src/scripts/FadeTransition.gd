extends ColorRect


signal animation_finished

# Signals

func _on_FadeAnimation_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished", anim_name)

# Tools

func fade_in() -> void:
	$FadeAnimation.play("fade_in")


func fade_out() -> void:
	$FadeAnimation.play("fade_out")
