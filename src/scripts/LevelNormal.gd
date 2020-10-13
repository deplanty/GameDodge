extends LevelBase


onready var bonus_scene := preload("res://src/actors/Bonus.tscn")
onready var coin_bonus_scene := preload("res://src/actors/CoinBonus.tscn")


func _ready() -> void:
	pass

# Signals

func _on_Player_first_jump() -> void:
	._on_Player_first_jump()
	$Bonus/BonusTimer.start()


func _on_BonusTimer_timeout() -> void:
	var bonus := bonus_scene.instance()
	bonus.init(round(rand_range(40, 360)), -8)
	bonus.connect("caught", self, "_on_Bonus_caught")
	$Bonus.add_child(bonus)


func _on_Bonus_caught() -> void:
	call_deferred("add_bonus_coin")

# Tools

func add_bonus_coin() -> void:
	for i in range(5):
		var coin = coin_bonus_scene.instance()
		var x := round(rand_range(40, 360))
		var y := round(rand_range(-8, -64))
		coin.init(x, y)
		coin.connect("caught", self, "_on_CoinBonus_caught")
		$Coins.add_child(coin)


func set_all_physics_process(state: bool) -> void:
	.set_all_physics_process(state)
	for bonus in $Bonus.get_children():
		bonus.set_physics_process(state)
