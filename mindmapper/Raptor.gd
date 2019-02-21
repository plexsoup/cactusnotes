"""

Raptors are enemies in the defense challenge.

They'll fly towards random nodes and eat them.



"""

extends Area2D

enum STATES { normal, burning, eating }
var CurrentState = STATES.normal

onready var global = get_node("/root/global")
var CurrentScene
var Velocity
var Speed = 150
var Target
var Health = 10
var DPSIntake = 3
var DPSOutput = 10

var Ticks = 0

signal hit(damage)


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	CurrentScene = global.getRootSceneManager().getCurrentScene()

	Speed *= (randf() + 0.5)
	getNewTarget()
	
	$AnimatedSprite.set_frame(randi()%3)
	$AnimatedSprite.play()

func setState(state):
	CurrentState = state

	if state == STATES.burning:
		$AnimationPlayer.play("burn")


func updateHealth(delta):
	if CurrentState == STATES.burning:
		Health -= DPSIntake * delta * global.GameSpeed

	if Health < 0:
		queue_free()

func getNewTarget():
	Target = CurrentScene.getRandomGraphNode()

func move(myPos, targetPos, delta):
	var vectorToTarget = targetPos - myPos
	vectorToTarget = vectorToTarget.normalized()
	Velocity = vectorToTarget * Speed * delta * global.GameSpeed
	
	if Velocity.x < 0:
		$AnimatedSprite.set_flip_h(true)
	else:
		$AnimatedSprite.set_flip_h(false)
	
	set_global_position(myPos + Velocity)

func targetExists(target):
	if is_instance_valid(target):
		return true
	else:
		return false

func moveToTarget(delta):
	var targetPos = Target.get_global_position()
	var myPos = get_global_position()
	var minDistSq = 6000
	if myPos.distance_squared_to(targetPos) > minDistSq:
		move(myPos, targetPos, delta)
	
func atTarget(target):
	if overlaps_body(target):
		return true
	else:
		return false

func eatTarget(target, delta):
	var streamScenes = [preload("res://effects/munch1.ogg"), preload("res://effects/munch2.ogg"), preload("res://effects/munch3.ogg")]
	var munchingNoise = $munchingNoise
	if munchingNoise.is_playing() == false:
		munchingNoise.set_stream(streamScenes[randi()%streamScenes.size()])	
		$munchingNoise.play()
	if target.has_method("_on_hit") and is_connected("hit", target, "_on_hit"):
		emit_signal("hit", DPSOutput * delta * global.GameSpeed)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1
	
	updateHealth(delta)
	
	if targetExists(Target) == false:
		getNewTarget()
	moveToTarget(delta)
		
	if atTarget(Target):
		eatTarget(Target, delta)
#


	
func _on_burn(damage):
	# the magnifying glass is trying to kill you
	setState(STATES.burning)
	$AnimationPlayer.play("burn")
	DPSIntake = damage

	
	
	

func _on_Raptor_body_entered(body):
	#print("raptor found ", body.name)
	if body.has_method("_on_hit"):
		if is_connected("hit", body, "_on_hit") == false:
			connect("hit", body, "_on_hit")
			
		

