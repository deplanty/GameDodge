extends Node


# Config file
const path_res := "res://assets/files/skins.ini"
var _cfg := ConfigFile.new()
# Parameters
var color :Color
var accent :Color
var rain_tail_gradient := GradientTexture.new()

# Initialize

func _ready() -> void:
	_cfg.load(path_res)


func load_skin(name: String):
	color = _cfg.get_value(name, "color")
	accent = _cfg.get_value(name, "accent")
	# Gradient
	var ramp = _cfg.get_value(name, "rain_tail_gradient")
	var gradient = Gradient.new()
	gradient.set_color(0, ramp[0])
	gradient.set_color(1, ramp[1])
	rain_tail_gradient.gradient = gradient
