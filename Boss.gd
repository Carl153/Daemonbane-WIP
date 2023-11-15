extends KinematicBody2D

const GRAVITY = 10
const SPEED = 150  # Speed increased to 3 times
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var direction = 1
var health = 10  # Health set to 10

var is_dead = false
var can_move = true
var can_change_direction = true

# Timers
var pause_timer = Timer.new()
var move_timer = Timer.new()
var direction_change_timer = Timer.new()
var attack_timer = Timer.new()
var walk_timer = Timer.new()

onready var health_bar = $ProgressBar

func _ready():
	add_to_group("Enemy")
	
	setup_timer(pause_timer, 2, "_on_pause_timer_timeout")
	setup_timer(move_timer, 7, "_on_move_timer_timeout")
	setup_timer(direction_change_timer, 0.5, "_on_direction_change_timer_timeout")
	setup_timer(attack_timer, 5, "_on_attack_timer_timeout")
	setup_timer(walk_timer, 4, "_on_walk_timer_timeout")

	move_timer.start()
	health_bar.max_value = 100
	health_bar.value = health * 10  # Adjusted for 10 lives

func setup_timer(timer, wait_time, method_name):
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", self, method_name)
	add_child(timer)

func _on_pause_timer_timeout():
	can_move = true
	attack_timer.start()

func _on_move_timer_timeout():
	can_move = false
	pause_timer.start()

func _on_direction_change_timer_timeout():
	can_change_direction = true

func _on_attack_timer_timeout():
	$AnimatedSprite.play("attack")
	walk_timer.start()

func _on_walk_timer_timeout():
	$AnimatedSprite.play("walk")
	move_timer.start()

func take_damage():
	health -= 2
	health_bar.value = health * 10
	if health <= 0:
		die()
	else:
		$AnimatedSprite.play("take_hit")

func die():
	is_dead = true
	$AnimatedSprite.play("dead")
	$AttackSound.play()
	set_physics_process(false)
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	yield($AnimatedSprite, "animation_finished")
	queue_free()

func _physics_process(delta):
	if is_dead:
		return

	if can_move:
		velocity.x = SPEED * direction
		velocity.y += GRAVITY

		if not $AnimatedSprite.is_playing():
			$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = (velocity.x < 0)
	else:
		velocity.x = 0
		if not $AnimatedSprite.is_playing():
			$AnimatedSprite.play("idle")

	velocity = move_and_slide(velocity, FLOOR)

	if (is_on_wall() and can_change_direction):
		direction *= -1
		can_change_direction = false
		direction_change_timer.start()

	handle_player_collision()

func handle_player_collision():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if "Player" in collision.collider.name:
			health -= 1
			health_bar.value = health * 10
			if health <= 0:
				die()
			break
			
func _on_Area2D_body_entered(body):
	# Implement your logic here when a body enters the Area2D
	pass

