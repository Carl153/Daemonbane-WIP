extends "res://MainHud.gd"

func _on_BlackGem_body_entered(body):
	if body.name == "Player":
		get_node("/root/Mainhud").score += 200
		get_node("/root/Mainhud").GemCounter += 1
		queue_free() # deletes the gem
	pass
