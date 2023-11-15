extends Node


export var mainGameScene : PackedScene

func _on_NewGame_button_up():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Intro.tscn")
	


func _on_Controls_pressed():
# warning-ignore:return_value_discarded
	 get_tree().change_scene("res://Controls.tscn")


func _on_Exit_pressed():
	get_tree().quit()
