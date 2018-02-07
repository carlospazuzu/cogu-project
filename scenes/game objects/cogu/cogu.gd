extends KinematicBody2D

const GRAVITY = 520 * 2
const MOVE_SPEED = 172 * 2
const RUN_DELAY = 5
const JUMP_FORCE = 390 * 2
const MAX_JUMP_AIRBONE = 13

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
var is_jumping = true #must change it later to false because player will always start on ground
var start_smooth_fall = false
var gravity_stomp = false
var is_shooting = false

# projectiles
onready var bullet = preload('res://scenes/game objects/projectiles/bullet.tscn')
# animation state handler
var current_animation_state = 'idle'

func _ready():
	pass

func _input(event):
	# firing bullets routine
	if event.is_action_pressed('shoot'):
		$bullet_sound.play()
		is_shooting = true
		$"Timers/Shooting Timer".start()
		var b = bullet.instance()
		b.direction = last_direction
		b.position.x = position.x + (22 * last_direction)
		b.position.y = position.y + 9
		get_parent().add_child(b)

func _physics_process(delta):
	var force = Vector2(0, GRAVITY)
	
	var moving_right = Input.is_action_pressed('ui_right')
	var moving_left = Input.is_action_pressed('ui_left')
	var pressing_jump = Input.is_action_pressed('jump')
	
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
	# to avoid player jump while is on air	
	may_jump = true if is_on_floor() else false
	
	if Input.is_action_just_pressed('jump') and may_jump:
		is_jumping = true
		may_run = true # avoid run delay while jumping
	
	# while player is pressing jump button and is_jumping is triggered, send him up	
	if is_jumping and pressing_jump:
		force.y = -JUMP_FORCE
		jump_offset += 1
		if jump_offset >= MAX_JUMP_AIRBONE:	
			jump_offset = 0
			gravity_stomp = true
			smooth_fall_var = GRAVITY
			is_jumping = false # CHANGE THIS NAME CUZ SHOULD BE JUMPING ROUTINE
	elif not pressing_jump and is_jumping:
		jump_offset = 0
		smooth_fall_var = JUMP_FORCE
		start_smooth_fall = true
		is_jumping = false # CHANGE THIS NAME CUZ SHOULD BE JUMPING ROUTINE
	# I guess it does the same of the if imediatally below
	# it is supposed to make character reach its max jump point and fall smoothly
	if gravity_stomp:		
		force.y -= smooth_fall_var
		smooth_fall_var -= 40 * 2
		if smooth_fall_var < 0: smooth_fall_var = 0
		if is_on_floor(): gravity_stomp = false
	
	# routine to make player falls smoothly and original game does
	# it is supposed to, when player releases jump button, it starts falling
	if start_smooth_fall:
		smooth_fall_var -= 30 * 2
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
		current_animation_state = 'idle' if not is_shooting else 'shoot'
	elif direction != 0 and not may_run:
		current_animation_state = 'start run'
	elif direction != 0 and may_run:
		current_animation_state = 'run' if not is_shooting else 'run n shoot'
		
	if not is_on_floor():
		current_animation_state = 'jump' if not is_shooting else 'jump n shoot'
		
	# only start moving if passed running delay
	if may_run:
		force.x = MOVE_SPEED * direction
	
	$AnimatedSprite.play(current_animation_state)
	$AnimatedSprite.flip_h = true if last_direction == -1 else false
	
	move_and_slide(force,  Vector2(0, -1))	
	
	# keep track of last direction to make moving stuff delay with animation works
	last_direction_animation = direction if direction != 0 else last_direction_animation
	

func _on_Shooting_Timer_timeout():
	is_shooting = false
