extends Control


signal buy(price)
signal request_update(section)


var section :String
var item :String
var price :int
var state :String


func set_item(section_name: String, name: String) -> void:
	section = section_name
	item = name
	price = Shop.get_value(section, name)

	update_item()


func update_item() -> void:
	$Title.text = "LABEL_SHOP_%s_%s" % [section.to_upper(), item.to_upper()]

	# Selected item
	if Preferences.get_value("shop", section.to_lower()) == item:
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
		$Button.text = "LABEL_SELECT"
		$Button.disabled = false
		$Button/Control.hide()


func _on_Button_pressed() -> void:
	# Buy or select the item

	if state == "buyable":
		Shop.buy(section, item)
		set_item(section, item)
		emit_signal("buy", price)
		_on_Button_pressed()
	elif state == "available":
		if section == "GAME_MODE":
			Globals.game_mode_selected = "GAME_MODE_" + item.to_upper()
			Preferences.set_value("shop", section.to_lower(), item)
			emit_signal("request_update", section)
		elif section == "WORLD_SKIN":
			Globals.set_world_skin(item)
			Preferences.set_value("shop", section.to_lower(), item)
			Skins.load_skin(item)
			emit_signal("request_update", section)
		elif section == "PLAYER_SKIN":
			Globals.set_player(item)
			Preferences.set_value("shop", section.to_lower(), item)
			emit_signal("request_update", section)
