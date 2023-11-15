extends KinematicBody2D

const SPEED = 180
const GRAVITY = 20
const JUMP_POWER = -550
const FLOOR = Vector2(0, -1)
const ROLL_SPEED = 300

var is_active = true
var is_dead = false
var velocity = Vector2()
var facing_direction = 1  # 1 for right, -1 for left
var on_ground = false
var is_attacking = false
var is_rolling = false
var health = 3
var is_dialogue_active = false
var roll_timer = Timer.new()  # Timer for controlling the duration of the roll

signal player_hurt(new_health)
signal dialogue_started
signal dialogue_finished
signal killed

func _ready():
	$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	roll_timer.connect("timeout", self, "_on_roll_timer_timeout")
	add_child(roll_timer)

func _physics_process(delta):
	if is_active and not is_dead:
		if not is_rolling:  # Add this check
			handle_movement()
			handle_jump()
			handle_attack()
		handle_gravity_and_motion()
		check_for_collisions()

func handle_movement():
	if Input.is_action_just_pressed("ui_dodge") and not is_attacking and not is_rolling:
		start_roll()
	elif is_rolling:
		return  # Skip other movement handling while rolling
	elif Input.is_action_pressed("ui_right"):
		if not is_attacking:
			facing_direction = 1
			velocity.x = SPEED
			$AnimatedSprite.play("run")
			$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		if not is_attacking:
			facing_direction = -1
			velocity.x = -SPEED
			$AnimatedSprite.play("run")
			$AnimatedSprite.flip_h = true
	else:
		velocity.x = 0
		if on_ground and not is_attacking and not is_rolling:
			$AnimatedSprite.play("idle")

func start_roll():
	is_rolling = true
	velocity.x = ROLL_SPEED * facing_direction
	$AnimatedSprite.play("roll")
	roll_timer.start(0.5)  # Duration of the roll

	# Disable collision with enemies
	set_collision_mask_bit(1, false)  # Assuming enemies are on layer 2

func handle_jump():
	if on_ground and Input.is_action_just_pressed("ui_up") and not is_attacking and not is_rolling:
		velocity.y = JUMP_POWER
		on_ground = false

func handle_attack():
	if Input.is_action_just_pressed("ui_focus_next") and not is_attacking and not is_rolling:
		is_attacking = true
		$AnimatedSprite.play("attack")
		
		# Assuming that the collision shape is on the right when the facing_direction is 1
		# The position is flipped when the facing direction is -1 (left)
		$Area2D/CollisionShape2D.position.x = $Area2D/CollisionShape2D.position.x * facing_direction
		
		# Enable the CollisionShape2D for the attack
		$Area2D/CollisionShape2D.disabled = false



func handle_gravity_and_motion():
	velocity.y += GRAVITY
	if is_on_floor():
		if not on_ground:
			on_ground = true
			if not is_attacking and not is_rolling:
				$AnimatedSprite.play("idle")
	else:
		on_ground = false
		if not is_attacking and not is_rolling:
			$AnimatedSprite.play("jump" if velocity.y < 0 else "fall")
	velocity = move_and_slide(velocity, FLOOR)

func check_for_collisions():
	if is_rolling:  # Skip collision checks while rolling
		return

	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if "Enemy" in collision.collider.name:
				take_damage()

				
func take_damage():
	if is_rolling:  # Ignore damage when rolling
		return
	health -= 1
	emit_signal("player_hurt", health)
	if health > 0:
		# Player still has health left, so play hurt animation instead of dying
		$AnimatedSprite.play("hurt")
		# Implement any knockback or invincibility frames here
	else:
		dead()  # Only call dead if health is 0 or less

func dead():
	is_dead = true
	# Change scene only if health is 0
	if health <= 0:
		get_tree().change_scene("Dead.tscn")
	# Else, play dead animation, disable collision, etc.
	velocity = Vector2.ZERO
	$AnimatedSprite.play("dead")
	$CollisionShape2D.disabled = true
	# No need to start the timer here as we're not immediately changing the scene

func _on_Timer_timeout():
	get_tree().change_scene("Dead.tscn")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		is_attacking = false
		
		# Reset the CollisionShape2D to the default side (right side)
		$Area2D/CollisionShape2D.position.x = abs($Area2D/CollisionShape2D.position.x)
		
		# Disable the CollisionShape2D as the attack is over
		$Area2D/CollisionShape2D.disabled = true
		# Flip the collision shape back if the player is still facing left
		if facing_direction == -1:
			$Area2D/CollisionShape2D.position.x *= -1
		
	elif not is_rolling and not is_attacking:
		if on_ground:
			$AnimatedSprite.play("idle")
		else:
			$AnimatedSprite.play("fall")


func _on_roll_timer_timeout():
	is_rolling = false

	# Re-enable collision with enemies
	set_collision_mask_bit(1, true)  # Assuming enemies are on layer 2

func _on_enemy_collision():
	# Decrease player lives by 1
	get_node("/root/MainHud").Lives -= 1

func _input(event):
	if is_active and is_dead:
		return

func player_hurt(new_health):
	# Update the player's health
	health = new_health

	# Check if the health bar exists and update its value
	if ProgressBar:
		ProgressBar.value = health * (ProgressBar.max_value / 3)  # Assuming max health is 3

	# Check if the player is dead
	if health <= 0:
		# Player has no health left, so trigger the death sequence
		is_dead = true
		emit_signal("killed")  # If you have a signal for when the player is killed
		$AnimatedSprite.play("dead")  # Make sure there's a 'dead' animation
		set_physics_process(false)  # Stop physics processing
		# Optionally disable player input and other gameplay elements here

		# Wait for the death animation to finish, then change the scene
		yield($AnimatedSprite, "animation_finished")
		get_tree().change_scene("Dead.tscn")
	else:
		# Player still has health left, so play a hurt animation if it exists
		$AnimatedSprite.play("hurt")  # Ensure you have a 'hurt' animation
		# Implement any additional logic for when the player is hurt but not dead
		# such as knockback, invincibility frames, etc.



func _on_Area2D_body_entered(body):
	if is_attacking and body.has_method("take_damage"):
		body.take_damage()
