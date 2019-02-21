extends Tree

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
var MindManager
var Ticks : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	MindManager = global.getRootSceneManager().getCurrentScene()


func updateTree():
	var tree = self
	tree.clear()
	var treeRoot = tree.create_item()
	tree.set_hide_root(true)
	
	for node in MindManager.get_node("graphNodes").get_children():
		var newTreeNode = tree.create_item(treeRoot)
		newTreeNode.set_text(0, node.name)
	



		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1
	if Ticks % 120 == 0:
		updateTree()
