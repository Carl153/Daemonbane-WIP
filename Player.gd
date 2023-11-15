extends KinematicBody2D

const SPEED = 150
const GRAVITY = 20
const JUMP_POWER = -350
const FLOOR = Vector2(0, -1)
const ROLL_SPEED = 150

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
	roll_timer.start(0.5)  # Adjust the duration of the roll as needed

func handle_jump():
	if on_ground and Input.is_action_just_pressed("ui_up") and not is_attacking and not is_rolling:
		velocity.y = JUMP_POWER
		on_ground = false

func handle_attack():
	if Input.is_action_just_pressed("ui_focus_next") and not is_attacking and not is_rolling:
		$AnimatedSprite.play("attack")
		is_attacking = true
		# Remove the check for is_on_floor() to allow attacking in the air

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
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if "Enemy" in collision.collider.name:
				dead()

func dead():
	is_dead = true
	health -= 1
	if health <= 0:
		get_tree().change_scene("GameOverScreen.tscn")
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite.play("dead")
		$CollisionShape2D.disabled = true
		$Timer.start()
		emit_signal("player_hurt", health)

func _on_Timer_timeout():
	get_tree().change_scene("GameOverScreen.tscn")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		is_attacking = false
	elif $AnimatedSprite.animation == "roll":
		if not roll_timer.is_stopped():
			roll_timer.stop()
		is_rolling = false
	if on_ground:
		$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.play("fall")

func _on_roll_timer_timeout():
	is_rolling = false

func _on_enemy_collision():
	# Decrease player lives by 1
	get_node("/root/MainHud").Lives -= 1

func _input(event):
	if is_active and is_dead:
		return

func player_hurt(new_health):
	if is_dead:
		return
	health = new_health
	if health <= 0:
		get_tree().change_scene("res://TitleScreen.tscn")
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite.play("dead")
		$CollisionShape2D.disabled = true
		$Timer.start()
		emit_signal("player_hurt", health)
