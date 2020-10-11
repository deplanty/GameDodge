extends Control


var highscores := Dictionary()  # All mode highscores
var highscore := Array()  # Current mode highscores
onready var mode_selected = $"/root/Globals".mode_selected
var next_scene := String()


func _ready() -> void:
	$FadeTransition.fade_out()
	highscores = $"/root/Globals".load_highscores()
	highscore = highscores[mode_selected]
	
	var score = $"/root/Globals".score
	$ScoreValue.text = str(score)
	
	# If score is a highscore
	if score > highscore[-1][1]:
		$ScoreLabel.text = "Nouveau record !"
		$Name.visible = true
		$Buttons.visible = false
		$Name/NameEdit.grab_focus()
	# If score is not a highscore
	else:
		$Name.visible = false
		$Buttons.visible = true
		$Buttons/RestartButton.grab_focus()

# Signals

func _on_NameEdit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		if $Name/NameEdit.text == "":
			return
		add_highscore($Name/NameEdit.text, get_node("/root/Globals").score)
		$Name.visible = false
		$Buttons.visible = true
		$Buttons/RestartButton.grab_focus()


func _on_RestartButton_pressed() -> void:
	next_scene = "res://src/actors/Level.tscn"
	$FadeTransition.fade_in()


func _on_MainMenuButton_pressed() -> void:
	next_scene = "res://src/actors/MainMenu.tscn"
	$FadeTransition.fade_in()


func _on_HighscoreButton_pressed() -> void:
	$FadeTransition.fade_in()
	next_scene = "res://src/actors/Highscore.tscn"


func _on_FadeTransition_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene(next_scene)

# Highscore

func custom_highscore_sort(a, b):
	return a[1] > b[1]


func add_highscore(name: String, score: int) -> void:
	# Add current score and sort them
	highscore.append([name, score])
	highscore.sort_custom(self, "custom_highscore_sort")
	highscore.pop_back()
	# Write highscores
	highscores[mode_selected] = highscore
	get_node("/root/Globals").save_highscores(highscores)
