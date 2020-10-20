extends Node

"""
Game statistics
"""

var patterns_dodged := 0
var rains_dodged := 0

var coins_caught := 0
var coins_lost := 0
var bonus_caught := 0
var bonus_lost := 0
var bonus_coins_caught := 0
var bonus_coins_lost := 0


func reset() -> void:
	var patterns_dodged := 0
	var rains_dodged := 0

	var coins_caught := 0
	var bonus_caught := 0
	var bonus_coins_caught := 0

	var coins_lost := 0
	var bonus_lost := 0
	var bonus_coins_lost := 0
