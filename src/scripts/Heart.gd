extends Node


signal animation_shrink_finished


func _ready() -> void:
	$AnimatedSprite.frame = 0

# Signals

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "shrink":
		var current_frame = $AnimatedSprite.frame
		$AnimatedSprite.play("empty")
		$AnimatedSprite.frame = current_frame
		emit_signal("animation_shrink_finished")
		$AnimatedSprite/AnimationPlayer.play("expand")


# Tools

func set_empty() -> void:
	$AnimatedSprite/AnimationPlayer.play("shrink")
