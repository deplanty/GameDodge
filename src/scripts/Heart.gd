extends AnimatedSprite


signal animation_shrink_finished


func _ready() -> void:
	frame = 0

# Signals

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "shrink":
		var current_frame = frame
		play("empty")
		frame = current_frame
		emit_signal("animation_shrink_finished")
		$AnimationPlayer.play("expand")


# Tools

func set_empty() -> void:
	$AnimationPlayer.play("shrink")
