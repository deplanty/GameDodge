extends Control


onready var heart_scene := preload("res://src/actors/Heart.tscn")
var life_current := 0

# Tools

func set_max_life(life: int) -> void:
	life_current = life
	# Remove previous childs
	for child in $Hearts.get_children():
		child.queue_free()
	# Add new hearts
	for i in range(life):
		var heart := heart_scene.instance()
		$Hearts.add_child(heart)


func set_life(life: int) -> void:
	$Hearts.get_child(life).set_empty()
