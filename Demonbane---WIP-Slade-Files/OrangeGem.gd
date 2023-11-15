extends "res://MainHud.gd"

func _on_OrangeGem_body_entered(body):
	if body.name == "Player":
		get_node("/root/Mainhud").score += 100
		get_node("/root/Mainhud").GemCounter += 1
		queue_free() # deletes the gem
	pass


