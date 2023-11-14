extends "res://MainHud.gd"



func _on_GreenGem_body_entered(body):
	if body.name == "Player":
		get_node("/root/Mainhud").score += 400
		get_node("/root/Mainhud").GemCounter += 1
		queue_free() # deletes the gem
	pass
