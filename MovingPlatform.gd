extends KinematicBody2D

export var move_speed = 1
export var move_distance = 200 # assuming each block is 1 unit
export var move_direction = Vector2(0, 1) # direction to move down

var time_since_init = 0
var origin = Vector2()

func _ready():
	origin = position

func _physics_process(delta):
	time_since_init += delta
	var position_on_curve = sin(time_since_init * move_speed)
	var offset = (move_distance / 2) * position_on_curve * move_direction # The amplitude is half the total move distance
	position = origin + offset

