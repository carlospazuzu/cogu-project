extends KinematicBody2D

const SPEED = 580
var direction = 1

# basically what bullet does is move in the direction the player is
# facing, check if the collided body is a game object which has the
# handle collision method (enemies which are destructable does have)
# and then destroy the instance and decrease from player the number
# of current active bullets (which the max is 3)

func _ready():
	pass

func _physics_process(delta):
	var motion = Vector2(SPEED * delta * direction, 0)
	move_and_collide(motion)

# if the collided body has handle collision method, call it
func _on_Area2D_body_entered( body ):
	pass
