extends KinematicBody2D

# Signals
signal first_jump
signal lose_life

# Movement
var first_move := false
export var gravity := 1000.0
export var speed := Vector2(200.0, 300.0)
var velocity := speed

# Life
var life := 3
var invulnerability := false


func _physics_process(delta: float) -> void:
	# Move only if the player has made it's first choice
	if not first_move:
		return

	# Bounce on wall
	if is_on_wall():
		$AudioBounce.play()
		velocity.x *= -1
		set_sprite_direction()

	# Update player position
	velocity.y += gravity * delta
	velocity.y = move_and_slide(velocity, Vector2.UP).y

# Signals

func _on_Timer_timeout() -> void:
	invulnerability = false
	set_collision_layer_bit(0, true)
	set_sprite_direction()

# Tools

func set_sprite_direction() -> void:
	if invulnerability:
		return
	if velocity.x < 0:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("left")
	else:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("right")


func jump() -> void:
	if not first_move:
		emit_signal("first_jump")
	first_move = true
	$AudioJump.play()
	set_sprite_direction()
	$JumpAnimation.frame = 0
	$JumpAnimation.play()


func jump_left() -> void:
	velocity.x = -speed.x
	velocity.y = -speed.y
	jump()


func jump_right() -> void:
	velocity.x = speed.x
	velocity.y = -speed.y
	jump()


func jump_mainmenu() -> void:
	"""
	Jump in the current direction.
	Used for the title screen.
	"""
	
	velocity.y = -speed.y
	jump()


func touch_lava() -> void:
	velocity.y = -speed.y * 2.5
	lose_life()


func lose_life() -> void:
	if not invulnerability:
		$AudioHurt.play()
		# Set invulnerability
		invulnerability = true
		$Timer.start()
		set_collision_layer_bit(0, false)
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("shiny")
		$AnimatedSprite/FadeAnimation.play("fade")
		# Lose  life
		life -= 1
		emit_signal("lose_life")
