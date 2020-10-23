extends Node

"""
Game statistics
"""

var patterns_dodged := 0
var rains_dodged := 0

var duration_msec := 0

var coins_caught := 0
var coins_lost := 0
var bonus_caught := 0
var bonus_lost := 0
var bonus_coins_caught := 0
var bonus_coins_lost := 0


func reset() -> void:
	patterns_dodged = 0
	rains_dodged = 0

	duration_msec = 0

	coins_caught = 0
	coins_lost = 0
	bonus_caught = 0
	bonus_lost = 0
	bonus_coins_caught = 0
	bonus_coins_lost = 0
