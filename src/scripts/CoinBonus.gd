extends KinematicBody2D


signal caught


export var velocity := Vector2(0, 100)


func _physics_process(delta: float) -> void:
	move_and_slide(velocity)

	if position.y > Globals.parameters.get_value("viewport", "height"):
		queue_free()

# Signals

func _on_Detector_body_entered(body: Node) -> void:
	if body.name == "Player":
		set_physics_process(false)
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("delete")
		$Particles2D/Timer.start()
		$Particles2D.emitting = true
		$LightOccluder2D.visible = false
		$Detector.disconnect("body_entered", self, "_on_Detector_body_entered")
		emit_signal("caught")


func _on_Timer_timeout() -> void:
	queue_free()

# Tools

func init(coords: Vector2) -> void:
	position = coords
