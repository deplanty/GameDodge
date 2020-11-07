extends Node2D


func _ready() -> void:
	update_tile_set()


func update_tile_set() -> void:
	$Roof.tile_set = Globals.tileset
	$Walls.tile_set = Globals.tileset
	$Lava.tile_set = Globals.tileset
