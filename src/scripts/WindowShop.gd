extends Control


signal buy(price)
signal request_update(section)


onready var line_scene := preload("res://src/actors/WindowShopLine.tscn")


func _ready() -> void:
	# Set theme color
	$Border.color = Skins.accent

	for section in Shop.get_value("SHOP", "all"):
		var line = add_line(section)
		for key in Shop.get_section_keys(section):
			line.add_item(section, key)


func add_line(title: String):
	var line = line_scene.instance()
	line.set_title("LABEL_SHOP_" + title)
	line.connect("buy", self, "_on_Line_buy")
	line.connect("request_update", self, "_on_Line_request_update")
	$Scroll/List.add_child(line)

	return line


func _on_Line_buy(price: int):
	emit_signal("buy", price)

func _on_Line_request_update(section: String):
	emit_signal("request_update", section)
