extends Node2D

func _on_Restart_pressed():
	get_tree().change_scene("res://World1.tscn")

func _on_Quit_pressed():
	get_tree().quit()
