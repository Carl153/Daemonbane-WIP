extends Node2D

# Restart the current level
func _on_Start_Again_pressed():
	# Assuming 'Mainhud' is the correct path to the node where you store lives
	get_node("/root/Mainhud").lives = 5
	
	# This will reload the current scene
	var current_scene = get_tree().current_scene.filename
	get_tree().change_scene(current_scene)

# Quit the game and go to the Title Screen
func _on_Quit_pressed():
	_quit_game()

func _quit_game():
	# Change the scene to the Title Screen
	get_tree().change_scene("res://TitleScreen.tscn")
