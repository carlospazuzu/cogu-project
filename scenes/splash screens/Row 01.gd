extends Node

var child_array
var delay
var frame_count = 0
var start_delay = 750
var start_count = 0
var start_flipping = false

func _ready():
	child_array = range(0, get_child_count())
	delay = randi() % 125
	

func _process(delta):
	
	start_count += delta * 1000
	# before flipping delay
	if start_count >= start_delay:
		start_flipping = true
	# if there are still numbers in the array, increase frame counting
	if child_array.size() > 0 and start_flipping:
		frame_count += delta * 1000
	# if frame counting is bigger than delay, flip some random "pixel" in current row
	if frame_count >= delay and start_flipping:
		frame_count = 0
		delay = randi() % 125
		
		var chosen = randi() % child_array.size()
		
		get_child(child_array[chosen]).play()
		child_array.remove(chosen)
		
