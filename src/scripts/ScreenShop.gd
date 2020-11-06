extends Control


var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color
	# Set the total amount of coins
	$CoinsContainer/CoinsLabel.text = str(Shop.coins)
	# Show the screen
	$FadeTransition.fade_out()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_BackButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_WindowShop_buy(price: int) -> void:
	# When a purchase has been made

	$CoinsContainer/CoinsLabel.text = str(Shop.coins)


func _on_WindowShop_request_update(section: String) -> void:
	# When a skin has been selected
	$WorldTileMap.update_tile_set()
	$Background.color = Skins.color
