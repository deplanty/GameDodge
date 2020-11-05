extends KinematicBody2D


export var velocity := Vector2(200, 100)


func _ready() -> void:
	$Explosion/ExplosionTimer.wait_time = $Explosion.lifetime


func _physics_process(delta: float) -> void:
	# Bounce on wall
	if is_on_wall():
		velocity.x *= -1

	move_and_slide(velocity, Vector2.UP)

# Signals

func _on_Detector_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.lose_life()
		$Sprite.hide()
		$Explosion.emitting = true
		$Explosion/ExplosionTimer.start()


func _on_ExplosionTimer_timeout() -> void:
	"""
	After an explosion.
	"""

	queue_free()
