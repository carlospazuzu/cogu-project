extends KinematicBody2D

const GRAVITY = 320
const MOVE_SPEED = 86
const RUN_DELAY = 6
const JUMP_FORCE = 480
const MAX_JUMP_AIRBONE = 10

# running vars
var direction = 1
var last_direction = 1
var last_direction_animation = 1
var jump_offset = 0
var smooth_fall_var = 0

var run_delay_count = 0

# booleans 
var may_run = false
var may_jump = false
var is_jumping = false
var start_smooth_fall = false

var current_animation_state = 'idle'

func _ready():
	pass

func _physics_process(delta):
	var force = Vector2(0, GRAVITY)
	
	var moving_right = Input.is_action_pressed("ui_right")
	var moving_left = Input.is_action_pressed("ui_left")
	var pressing_jump = Input.is_action_pressed("jump")
	
	# handle left and right movement
	if moving_right:
		direction = 1
		last_direction = 1
	elif moving_left:
		direction = -1
		last_direction = -1
	else:
		direction = 0
		run_delay_count = 0
		may_run = false
		
	may_jump = true if is_on_floor() else false
	
	if Input.is_action_just_pressed("jump") and may_jump:
		is_jumping = true
		may_run = true # avoid run delay while jumping
		
	if is_jumping and pressing_jump:
		force.y -= JUMP_FORCE
		jump_offset += 1
		if jump_offset >= MAX_JUMP_AIRBONE:	
			jump_offset = 0
			start_smooth_fall = true
			smooth_fall_var = JUMP_FORCE
			is_jumping = false # CHANGE THIS NAME CUZ SHOULD BE JUMPING ROUTINE
	elif not pressing_jump and is_jumping:
		jump_offset = 0
		smooth_fall_var = JUMP_FORCE
		start_smooth_fall = true
		is_jumping = false # CHANGE THIS NAME CUZ SHOULD BE JUMPING ROUTINE
		
	# routine to make player falls smoothly and original game does
	if start_smooth_fall:
		smooth_fall_var -= 20
		if smooth_fall_var < 0: smooth_fall_var = 0
		force.y -= smooth_fall_var
		if is_on_floor():
			start_smooth_fall = false
		
	# if player is moving, start counting moving delay	
	if direction != 0:
		run_delay_count += 1
		if run_delay_count >= RUN_DELAY:
			may_run = true
			# if player suddenly changes direction while moving, reset delay
			if last_direction_animation != direction:
				may_run = false
				run_delay_count = 0
	
	# handle player animation states		
	if direction == 0:
		current_animation_state = 'idle'
	elif direction != 0 and not may_run:
		current_animation_state = 'start run'
	elif direction != 0 and may_run:
		current_animation_state = 'run'
		
	if not is_on_floor():
		current_animation_state = 'jump'
		
	# only start moving if passed running delay
	if may_run:
		force.x = MOVE_SPEED * direction
	
	$AnimatedSprite.play(current_animation_state)
	$AnimatedSprite.flip_h = true if last_direction == -1 else false
	
	move_and_slide(force,  Vector2(0, -1))	
	
	# keep track of last direction to make moving stuff delay with animation works
	last_direction_animation = direction if direction != 0 else last_direction_animation
	