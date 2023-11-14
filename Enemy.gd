extends KinematicBody2D

const GRAVITY = 10
const SPEED = 50
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var direction = 1
var health = 1


var is_dead = false
var can_move = true
var can_change_direction = true

# Timers for movement control
var pause_timer = Timer.new()
var move_timer = Timer.new()
var direction_change_timer = Timer.new()

func _ready():
	add_to_group("Enemy")
	# Set up the pause and move timers
	setup_timer(pause_timer, 2, "_on_pause_timer_timeout")
	setup_timer(move_timer, 10, "_on_move_timer_timeout")
	setup_timer(direction_change_timer, 0.5, "_on_direction_change_timer_timeout")  # Delay of 0.5 seconds before the character can change direction again
	
	# Start the movement timer which includes the first pause
	move_timer.start()

func setup_timer(timer, wait_time, method_name):
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", self, method_name)
	add_child(timer)

func _on_pause_timer_timeout():
	can_move = true
	move_timer.start()

func _on_move_timer_timeout():
	can_move = false
	pause_timer.start()

func _on_direction_change_timer_timeout():
	can_change_direction = true
	
func take_damage():
	health -= 1
	if health <= 0:
		die()
	else:
		$AnimatedSprite.play("take_hit")  # Ensure this animation exists.

func die():
	# Play the 'dead' animation
	
	$AnimatedSprite.play("dead")
	# Disable any further collision checks or processing
	set_physics_process(false)
	set_process(false)
	# Optionally, you can disable the collision shape if you don't want the dead enemy to be solid
	$CollisionShape2D.set_deferred("disabled", true)
	# Wait for the death animation to finish before removing the enemy
	yield($AnimatedSprite, "animation_finished")
	# Now, you can remove the enemy from the scene
	queue_free()
	
func _physics_process(delta):
	if is_dead:
		return

	if can_move:
		# If the character can move, apply movement and gravity
		velocity.x = SPEED * direction
		velocity.y += GRAVITY

		# Play the walk animation and handle sprite flipping
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = (velocity.x < 0)
	else:
		# If the character cannot move, set velocity to zero and play the idle animation
		velocity.x = 0
		$AnimatedSprite.play("idle")

	# Apply the velocity to the character
	velocity = move_and_slide(velocity, FLOOR)

	# Check for wall collision and change direction
	if (is_on_wall() and can_change_direction):
		direction *= -1
		can_change_direction = false
		direction_change_timer.start()

	handle_player_collision()



func handle_player_collision():
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if "Player" in collision.collider.name:
				# Reduce the enemy's health
				health -= 1

				# Check if the enemy is dead
				if health <= 0:
					die()  # Call the dead function if health is 0 or less

				# Emit a signal to the player if needed
				collision.collider.emit_signal("player_hurt", collision.collider.health)

				# Break after handling the player collision to avoid multiple health reductions in one frame
				break
				
				


func _on_Timer_timeout():
	queue_free()
