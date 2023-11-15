extends Control

var current_world_index = 1  # Start from World 1
var total_worlds = 7  # Assuming you have 7 worlds

# Ready function to set up the loading screen
func _ready():
		$Timer.wait_time = 3	
	$Timer.one_shot = true
	$Timer.start()
	$ProgressBar.value = 0
	update_progress_bar()

# Function to update the progress bar
func update_progress_bar():
	var progress = 0
	var max_progress = 100
	var increment = max_progress / $Timer.wait_time / 10 # Update 10 times per second

	while progress < max_progress:
		progress += increment
		$ProgressBar.value = progress
		yield(get_tree().create_timer(0.1), "timeout")

	$ProgressBar.value = max_progress

# Function to change the scene when Timer times out
func _on_Timer_timeout():
	# Increment world index to go to the next world
	current_world_index += 1
	
	# Ensure we loop back to World 1 if we exceed the total number of worlds
	if current_world_index > total_worlds:
		current_world_index = 1

	# Construct the path to the next world scene
	var next_world_path = "res://World" + str(current_world_index) + ".tscn"
	
	# Load the next world
	get_tree().change_scene(next_world_path)
