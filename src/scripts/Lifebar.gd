extends Control


func _ready() -> void:
	# Reset animations to zero
	for i in $Hearts.get_child_count():
		$Hearts.get_child(i).frame = 0


func set_life(life: int) -> void:
	$Hearts.get_child(life).set_empty()
