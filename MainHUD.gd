extends Node2D

var score = 0 setget set_score
onready var lives = 3 setget set_lives
var GemCounter = 0 setget set_counter


# Called when the node enters the scene tree for the first time.
func set_score(value):
	score = value
	$HUD/Score.set_text("SCORE: " + str(score))
	pass

func set_counter(value):
	GemCounter = value
	$HUD/Gems.set_text("GEMS x " + str(GemCounter))
	pass

func set_lives(value):
	lives = value
	$HUD/Lives.set_text("LIVES: " + str(lives))
	if lives <= 0:
		get_tree().change_scene("res://Dead.tscn")
	pass
