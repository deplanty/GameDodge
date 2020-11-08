extends KinematicBody2D

# Signals
signal first_jump
signal lose_life

# Movement
var first_move := false
onready var gravity :float= Settings.get_value("GAMEPLAY", "gravity")
onready var speed :Vector2= Settings.get_value("PLAYER", "speed")
onready var velocity := speed

const img_midair := 0
const img_jump := 1
const img_fall := 2

# Life
var life := int()
var invulnerability := false


func _ready() -> void:
	$Sprite.texture = Globals.player


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

	set_sprite_direction()

# Signals

func _on_Timer_timeout() -> void:
	invulnerability = false
	set_collision_layer_bit(0, true)
	set_sprite_direction()

# Look direction

func look_right() -> void:
	$Sprite.scale.x = 1


func look_left() -> void:
	$Sprite.scale.x = -1

# Jump

func jump() -> void:
	if not first_move:
		emit_signal("first_jump")
	first_move = true
	velocity.y = -speed.y
	$AudioJump.play()
	# Allow several jump cloud at the same time
	if not $Particules/JumpParticles1.emitting:
		$Particules/JumpParticles1.restart()
	elif not $Particules/JumpParticles2.emitting:
		$Particules/JumpParticles2.restart()
	elif not $Particules/JumpParticles3.emitting:
		$Particules/JumpParticles2.restart()
	else:
		$Particules/JumpParticles1.restart()
	set_sprite_direction()


func jump_left() -> void:
	velocity.x = -speed.x
	jump()


func jump_right() -> void:
	velocity.x = speed.x
	jump()

# Tools

func set_sprite_direction() -> void:
	if velocity.x < 0:
		look_left()
	else:
		look_right()

	if abs(velocity.y) < 40:
		$Sprite.frame = img_midair
	elif velocity.y < 0:
		$Sprite.frame = img_jump
	else:
		$Sprite.frame = img_fall


func touch_lava() -> void:
	velocity.y = -speed.y * 2.5
	lose_life()


func lose_life() -> void:
	if not invulnerability:
		$AudioHurt.play()
		# Set invulnerability
		invulnerability = true
		$Timer.start(Settings.get_value("PLAYER", "invulnerability_time"))
		set_collision_layer_bit(0, false)
		$Sprite/FadeAnimation.play("fade")
		# Lose  life
		life -= 1
		emit_signal("lose_life")
