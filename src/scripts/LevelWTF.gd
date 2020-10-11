extends "res://src/scripts/Level.gd"


var score_current := 0

# Signals

func _on_Coin_caught() -> void:
	"""
	Overwrite signal from parent.
	"""
	
	score_current += 1
	score = int(max(score_current, score))
	$Control/ScoreContainer/ValueScore/.text = str(score)
	$Control/ScoreContainer/ValueScoreCurrent/.text = str(score_current)
	# Add 2 coins
	call_deferred("add_coin")
	call_deferred("add_coin")


func _on_Coin_fall_in_lava() -> void:
	"""
	Overwrite signal from parent.
	"""
	
	score_current = int(max(0, score_current - 1))
	$Control/ScoreContainer/ValueScoreCurrent/.text = str(score_current)
	# Spawn new coin if no one remains
	if $Coins.get_child_count() == 0:
		# FIX: if 2 coins are queue_free() at the same time then child_count == 2
		call_deferred("add_coin")

# Tools

func on_death() -> void:
	$Player.invulnerability = true
	$"/root/Globals".score = score
	next_scene = "res://src/actors/GameOver.tscn"
	$Control/FadeTransition.fade_in()
