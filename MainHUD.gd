extends Node2D

var score = 0 setget set_score
onready var lives = 3 setget set_lives

func set_score(value):
	score = value
	$HUD/Score.set_text("SCORE: " + str(score))
	pass

func set_lives(value):
	lives = value
	$HUD/Lives.set_text("LIVES: " + str(lives))
	if lives <= 0:
		get_tree().change_scene("res://Scenes/TitleScreen.tscn")
	pass

func _ready():
	lives = 3
	set_hud_visibility()

func set_hud_visibility():
	var current_scene = get_tree().get_current_scene()
	print("Current Scene Path:", current_scene.get_path())  # Debug output

	if current_scene.get_path() == "res://World1.tscn" or current_scene.get_path() == "res://World2.tscn":
		self.show()
	else:
		self.hide()

# Connect this function to the scene_changed signal to update HUD visibility
func _on_scene_changed():
	set_hud_visibility()
