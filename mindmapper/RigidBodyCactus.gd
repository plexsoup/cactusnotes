extends RigidBody2D

# Declare member variables here. Examples:
var Health = 100

onready var global = get_node("/root/global")
var MindMapper
signal cactus_died(cactus)

# Called when the node enters the scene tree for the first time.
func _ready():
	MindMapper = global.getRootSceneManager().getCurrentScene()
	connect("cactus_died", MindMapper, "_on_cactus_died")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Health < 0:
		emit_signal("cactus_died", self)
		# we'll let the MindMapper handle our queue_free for now.
		# They also have to free up some DampedSpringJoint2Ds


func _on_hit(damage):
	Health -= damage
	