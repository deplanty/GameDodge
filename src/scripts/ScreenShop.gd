extends Control


var next_scene := String()


func _ready() -> void:
	$Background.color = Skins.color
	# Set the total amount of coins
	var total_coins = Shop.get_value("INVENTORY", "coins")
	$CoinsContainer/CoinsLabel.text = str(total_coins)
	# Set the shop
	set_shop()
	# Show the screen
	$FadeTransition.fade_out()


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)


func _on_BackButton_pressed() -> void:
	next_scene = "res://src/actors/screens/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_SelectButton_pressed(row: int, skin_name: String) -> void:
	Globals.tileset_name = skin_name
	Globals.tileset = load("res://assets/images/tilesets/%s.tres" % skin_name)
	Preferences.set_value("skins", "world", skin_name)
	Skins.load_skin(skin_name)

	for i in $Grid.get_child_count() / 2:
		if i == row:
			$Grid.get_child(i * 2 + 1).text = "Selected"
		else:
			$Grid.get_child(i * 2 + 1).text = "Select"

	$TileMap.tile_set = Globals.tileset
	$Background.color = Skins.color


# Tools

func set_shop() -> void:
	# Remove grid
	for child in $Grid.get_children():
		child.queue_free()

	var world_skins := Shop.get_world_skins()
	var row := 0
	for skin_name in world_skins:
		# Label
		var label := Label.new()
		label.text = skin_name
		$Grid.add_child(label)
		# Button
		var price = Shop.get_value("WORLD_SKINS", skin_name)
		var button := Button.new()
		if price > 0:
			button.text = "Buy %d" % price
		else:
			if Globals.tileset_name == skin_name:
				button.text = "Selected"
			else:
				button.text = "Select"
		button.connect("pressed", self, "_on_SelectButton_pressed", [row, skin_name])
		$Grid.add_child(button)

		row += 1
