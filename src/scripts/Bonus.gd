extends KinematicBody2D


signal caught
signal fall_in_lava


export var velocity := Vector2(0, 150)


func _physics_process(delta: float) -> void:
	move_and_slide(velocity)

	if position.y > Globals.parameters.get_value("VIEWPORT", "height"):
		emit_signal("fall_in_lava")
		queue_free()

# Signals

func _on_Detector_body_entered(body: Node) -> void:
	if body.name == "Player":
		set_physics_process(false)
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("explode")
		$Explosion.emitting = true
		$Explosion/Timer.start()
		$Detector.disconnect("body_entered", self, "_on_Detector_body_entered")
		emit_signal("caught")


func _on_Timer_timeout() -> void:
	queue_free()

# Tools

func init(coords: Vector2) -> void:
	position = coords
