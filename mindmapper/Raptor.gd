"""

Raptors are enemies in the defense challenge.

They'll fly towards random nodes and eat them.



"""

extends KinematicBody2D

enum STATES { normal, burning, eating }
var CurrentState = STATES.normal

onready var global = get_node("/root/global")
var CurrentScene
var Velocity
var Speed = 200
var Target
var Health = 10
var DamageRate = 3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	CurrentScene = global.getRootSceneManager().getCurrentScene()

	Target = CurrentScene.getRandomGraphNode()

func setState(state):
	CurrentState = state

	if state == STATES.burning:
		$AnimationPlayer.play("burn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vectorToTarget = Target.get_global_position() - get_global_position()
	vectorToTarget = vectorToTarget.normalized()
	Velocity = vectorToTarget * Speed * delta * global.GameSpeed
	
	if Velocity.x < 0:
		$AnimatedSprite.set_flip_h(true)
	else:
		$AnimatedSprite.set_flip_h(false)
		
	var collisionData = move_and_collide(vectorToTarget)
	if collisionData:
		#print(self.name, " ran into ", collisionData.get_collider().name)
		pass
		
	if CurrentState == STATES.burning:
		Health -= DamageRate * delta * global.GameSpeed

	if Health < 0:
		queue_free()
	
func _on_burn(damage):
	# the magnifying glass is trying to kill you
	setState(STATES.burning)
	$AnimationPlayer.play("burn")
	DamageRate = damage

	
	
	