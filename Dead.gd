extends Node2D

func _on_Start_Again_pressed():
	get_node("/root/Mainhud").lives = 5
	get_tree().change_scene("res://World1.tscn")
	pass # Replace with function body.



func _on_Quit_pressed():
	-_quit_game()
	pass # Replace with function body.

func _quit_game():
	# Access the OS class to quit the game
	if OS.has_feature("quit"):
		OS.quit()
	else:
		# If the platform does not support quitting, you can print a message or handle it accordingly
		print("Quit feature not supported on this platform.")
