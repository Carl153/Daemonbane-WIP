extends Area2D


func _on_Trap_body_entered(body):
	if body.name == "Player":
		get_node("/root/Mainhud").score -= 5
		get_node("/root/Mainhud").lives -= 10
		queue_free() 
	pass # Replace with function body.
