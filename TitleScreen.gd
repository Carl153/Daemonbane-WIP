extends Node


export var mainGameScene : PackedScene

func _on_NewGame_button_up():
	get_tree().change_scene("res://Intro.tscn")
	

func _on_Controls_pressed():
	 get_tree().change_scene("res://Controls.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_About_pressed():
	get_tree().change_scene("res://About.tscn")
