extends AnimatedSprite


func set_empty() -> void:
	play("empty")
	$AnimationPlayer.play("hurt")
