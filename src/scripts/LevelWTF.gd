extends LevelBase


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
	if $Coins.get_child_count() <= 1:  # 1: the queue_free() takes some time
		call_deferred("add_coin")
