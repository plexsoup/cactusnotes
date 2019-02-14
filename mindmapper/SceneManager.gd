extends Node2D

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
onready var FadeTransitions = get_node("FadeTransition")

var SceneOrder = ["res://TitleScene/TitleScene.tscn", "res://MindMapper.tscn"]

var CurrentSceneNode
var NextSceneNode

# Called when the node enters the scene tree for the first time.
func _ready():
	global.setRootSceneManager(self)
	spawnTitleScene()
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getCurrentScene():
	return CurrentSceneNode


func spawnTitleScene():
	var titleScene = preload("res://TitleScene/TitleScene.tscn")
	var newTitleScene = titleScene.instance()
	add_child(newTitleScene)
	
	FadeTransitions.fadeIn()

	CurrentSceneNode = newTitleScene
	
func launchMindMapper():
	var mindMapper = preload("res://Mindmapper.tscn")
	var newMindMapper = mindMapper.instance()
	NextSceneNode = newMindMapper
	fadeOut()
	
	
	
func fadeOut():
	FadeTransitions.fadeOut()
	
func launchNextScene(): # this happens after the fadeOut, but before the fadeIn
	print(self.name, " calling launchNextScene" )
	CurrentSceneNode.queue_free()
	CurrentSceneNode = NextSceneNode
	add_child(CurrentSceneNode)

	FadeTransitions.show()
	FadeTransitions.fadeIn()
	
	
func _on_FadeTransition_fadeOut_finished():
	print(self.name, " received signal: _on_FadeTransition_fadeOut_finished")
	launchNextScene()
	
func _on_FadeTransition_fadeIn_finished():
	# hide the FadeTransition node
	FadeTransitions.hide()
	
	