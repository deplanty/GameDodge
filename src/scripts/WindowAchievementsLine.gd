extends Control


func set_labels(title: String, description: String, reward: int) -> void:
	$ColorRect/Title.text = title
	$ColorRect/Description.text = description
	$ColorRect/Reward.text = str(reward)


func set_done(done: bool) -> void:
	if done:
		$ColorRect/Medal.show()
	else:
		$ColorRect/Medal.hide()
