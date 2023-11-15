extends Control

var current_world_index = 1  # Assuming you start from World 1
var total_worlds = 7  # Assuming you have 7 worlds

# Ready function to set up the loading screen and connect button signals
func _ready():
	$Timer.wait_time = 5  # Set the timer to 5 seconds
	$Timer.one_shot = true
	$ProgressBar.value = 0
	connect_buttons()

# Function to update the progress bar and load the scene after 5 seconds
func update_progress_bar_and_load(scene_path):
	var progress_per_second = 20  # Set the progress increment to 20%
	var total_progress = 100  # Total progress is 100%

	# Loop to increment the progress bar
	for i in range(5):  # 5 increments for 5 seconds
		$ProgressBar.value += progress_per_second
		yield(get_tree().create_timer(1.0), "timeout")  # Wait for 1 second

	# Ensure the progress bar is filled after 5 seconds
	$ProgressBar.value = total_progress
	
	# Load the specified scene
	get_tree().change_scene(scene_path)

# Function to handle map button press
# Function to handle map button press
func _on_MapButton_pressed(button_name):
	var scene_path = "res://"
	match button_name:
		"World1":
			scene_path += "World1.tscn"
		"World2":
			scene_path += "World2.tscn"
		"World3":
			scene_path += "World3.tscn"
		"World4":
			scene_path += "World4.tscn"
		"World5":
			scene_path += "World5.tscn"
		"World6":
			scene_path += "World6.tscn"
		"World7":
			scene_path += "World7.tscn"		
	# Start the progress bar and load the scene
	update_progress_bar_and_load(scene_path)

# Connect each button's "pressed" signal to the above function
func connect_buttons():
	for i in range(1, 8): # Connects World1 to World7
		var button = $Panel.get_node("World" + str(i))
		button.connect("pressed", self, "_on_MapButton_pressed", ["World" + str(i)])
