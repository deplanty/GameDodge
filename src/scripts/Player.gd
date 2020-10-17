extends KinematicBody2D

# Signals
signal first_jump
signal lose_life

# Movement
var first_move := false
onready var gravity :float= Globals.parameters.get_value("gameplay", "gravity")
onready var speed :Vector2= Globals.parameters.get_value("player", "speed")
onready var velocity := speed

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

# Look direction

func look_right() -> void:
	$AnimatedSprite.scale.x = 1


func look_left() -> void:
	$AnimatedSprite.scale.x = -1

# Jump

func jump() -> void:
	if not first_move:
		emit_signal("first_jump")
	first_move = true
	velocity.y = -speed.y
	$AudioJump.play()
	$AnimatedSprite.frame = 0
	$JumpAnimation.frame = 0
	$JumpAnimation.play()
	set_sprite_direction()


func jump_left() -> void:
	velocity.x = -speed.x
	jump()


func jump_right() -> void:
	velocity.x = speed.x
	jump()

# Tools

func set_sprite_direction() -> void:
	if invulnerability:
		return
	if velocity.x < 0:
		look_left()
		$AnimatedSprite.play("jump")
	else:
		look_right()
		$AnimatedSprite.play("jump")


func touch_lava() -> void:
	velocity.y = -speed.y * 2.5
	lose_life()


func lose_life() -> void:
	if not invulnerability:
		$AudioHurt.play()
		# Set invulnerability
		invulnerability = true
		$Timer.start(Globals.parameters.get_value("player", "invulnerability_time"))
		set_collision_layer_bit(0, false)
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("hurt")
		$AnimatedSprite/FadeAnimation.play("fade")
		# Lose  life
		life -= 1
		emit_signal("lose_life")
