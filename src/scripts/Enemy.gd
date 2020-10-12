extends KinematicBody2D


export var velocity := Vector2(200, 100)


func _physics_process(delta: float) -> void:
	# Bounce on wall
	if is_on_wall():
		velocity.x *= -1
	
	# Delete when on lava
	if is_on_floor():
		queue_free()

	move_and_slide(velocity, Vector2.UP)

# Signals

func _on_Detector_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.lose_life()
		queue_free()
