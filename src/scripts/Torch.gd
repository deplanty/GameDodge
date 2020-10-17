extends Node2D


func set_alert(on: bool) -> void:
	if on:
		$Light2D/GlowAnimation.play("alert_on")
	else:
		$Light2D/GlowAnimation.play("alert_off")
