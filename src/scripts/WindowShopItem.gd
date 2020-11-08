extends Control


signal buy(price)
signal request_update(section)


var section := String()
var price := int()
var state := String()


func set_item(section_name: String, name: String) -> void:
	section = section_name
	price = Shop.get_value(section, name)
	$Title.text = name

	# Selected item
	if Preferences.get_value("skins", section.to_lower()) == name:
		state = "selected"
		$Button.text = "LABEL_SELECTED"
		$Button.disabled = true
		$Button/Control.hide()
	# Buyable
	elif price > 0:
		state = "buyable"
		$Button.text = ""
		$Button.disabled = price > Shop.coins
		$Button/Control/Price/HBox/Value.text = str(price)
		$Button/Control.show()
	# Available
	else:
		state = "available"
		if section == "GAME_MODE":
			$Button.text = "LABEL_BOUGHT"
			$Button.disabled = true
		else:
			$Button.text = "LABEL_SELECT"
			$Button.disabled = false
		$Button/Control.hide()


func _on_Button_pressed() -> void:
	# Buy or select the item

	if state == "buyable":
		Shop.buy(section, $Title.text)
		set_item(section, $Title.text)
		emit_signal("buy", price)
	elif state == "available":
		if section == "WORLD_SKIN":
			Globals.set_world_skin($Title.text)
			Preferences.set_value("skins", section.to_lower(), $Title.text)
			Skins.load_skin($Title.text)
			emit_signal("request_update", section)
		elif section == "PLAYER_SKIN":
			Globals.set_player($Title.text)
			Preferences.set_value("skins", section.to_lower(), $Title.text)
			emit_signal("request_update", section)
