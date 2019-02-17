"""

GraphEdge is an edge between two graph nodes (RigidBodyNotes).

It should store a reference to each RigidBodyNote it's connected to, including their IDs for the JSON datastore.


"""

extends DampedSpringJoint2D

onready var global = get_node("/root/global")
var MindMapper

var Node_A_ID
var Node_B_ID

var Ticks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	MindMapper = global.getRootSceneManager().getCurrentScene()

func getNodeID(node):
	if node == null:
		return 0
	if node.has_node("StickyNote"):
		return node.get_node("StickyNote").getID()
	else:
		print(self.name, ": something's wrong in getNodeID. ", node, " doesn't have a StickyNote" )

func start(nodeA, nodeB):
	if nodeA != null and is_instance_valid(nodeA):
		set_node_a(get_path_to(nodeA))
		Node_A_ID = getNodeID(nodeA)
	if nodeB != null and is_instance_valid(nodeB):
		set_node_b(get_path_to(nodeB))
		Node_B_ID = getNodeID(nodeB)
	
	set_length(300)
	set_rest_length(150)
	set_stiffness(10)
	set_damping(0.1)

func isConnectedTo(node):
	if get_node(get_node_a()) == node or get_node(get_node_b()) == node:
		return true
	else:
		return false

func removeNodeConnection(node):
	if get_node(get_node_a()) == node:
		set_node_a("")
	if get_node(get_node_b()) == node:
		set_node_b("")
	
func getSaveData():
	return { "node_a_id": Node_A_ID, "node_b_id": Node_B_ID }

func loadSaveData(data):
	
	#start(MindMapper.getGraphNodeByID(data["nodeA"]), MindMapper.getGraphNodeByID(data["nodeB"]))
	pass
	# shouldn't be necessary if the node_id's are provided when the springs are spawned

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1
	
#	if Ticks % 200 == 0:
#		print(self.name, ": node_a == ", get_node_a())
#		print(self.name, ": node_b == ", get_node_b())

		
#	if is_instance_valid(get_node(get_node_a())):
	#update()

#func _draw():
#
#	var nodeA = get_node(get_node_a())
#	var nodeAPos = to_local(nodeA.get_position())
#
#	var nodeB = get_node(get_node_b())
#	var nodeBPos = to_local(get_node(get_node_b()).get_position())
#
#	var lineWidth = 3.0
#	draw_line(nodeAPos, nodeBPos, Color(0, 0.8, 0), lineWidth)
	