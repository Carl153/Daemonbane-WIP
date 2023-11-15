extends Node2D

func _ready():
	# Assuming the AnimatedSprite node is a direct child of the current node
	var animated_sprite = $AnimatedSprite
	animated_sprite.play("idle")
