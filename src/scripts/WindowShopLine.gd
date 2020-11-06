extends Control


signal buy(price)
signal request_update(section)


var item_scene := preload("res://src/actors/WindowShopItem.tscn")


func _ready() -> void:
	# Set theme color
	$Border.color = Skins.accent


func set_title(title: String) -> void:
	$Title.text = title


func add_item(section: String, name: String) -> void:
	var item := item_scene.instance()
	item.set_item(section, name)
	item.connect("buy", self, "_on_Item_buy")
	item.connect("request_update", self, "_on_Item_request_update")
	$Scroll/List.add_child(item)


func _on_Item_buy(price: int):
	emit_signal("buy", price)


func _on_Item_request_update(section: String):
	var names := Shop.get_section_keys(section)
	for i in $Scroll/List.get_child_count():
		var item = $Scroll/List.get_child(i)
		item.set_item(section, names[i])
	emit_signal("request_update", section)
