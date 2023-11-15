extends "res://MainHud.gd"


func _on_PinkGem_body_entered(body):
	if body.name == "Player":
		get_node("/root/Mainhud").score += 300
		get_node("/root/Mainhud").GemCounter += 1
		$Pickup.play()
		queue_free() # deletes the gem
	pass
