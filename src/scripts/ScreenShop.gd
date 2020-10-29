extends Control


var next_scene := String()


func _ready() -> void:
	# Set the total amount of coins
	var total_coins = Globals.shop.get_value("INVENTORY", "coins")
	$CoinsContainer/CoinsLabel.text = str(total_coins)
	# Show the screen
	$FadeTransition.fade_out()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_BackButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$FadeTransition.fade_in()
