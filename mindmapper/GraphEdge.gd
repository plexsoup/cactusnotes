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
	if node.has_node("StickyNote"):
		return node.get_node("StickyNote").getID()

func start(nodeA, nodeB):
	set_node_a(get_path_to(nodeA))
	set_node_b(get_path_to(nodeB))
	
	Node_A_ID = getNodeID(nodeA)
	Node_B_ID = getNodeID(nodeB)
	
	set_length(250)
	set_rest_length(150)
	set_stiffness(200)
	set_damping(1)

	
func getSaveData():
	return { "nodeA": Node_A_ID, "nodeB": Node_B_ID }

func loadSaveData(data):
	
	start(data["nodeA"], data["nodeB"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1
	
	if Ticks % 200 == 0:
		print("node_a == ", get_node_a())
		print("node_b == ", get_node_b())
		if is_instance_valid(get_node(get_node_a())) and is_instance_valid(get_node(get_node_b())):
			update()

func _draw():
	var nodeAPos = Vector2(0,0)
	var nodeBPos = Vector2(0,0)
	var nodeA = get_node(get_node_a())
	if is_instance_valid(nodeA):
		nodeAPos = to_local(nodeA.get_global_position())
	var nodeB = get_node(get_node_b())
	if is_instance_valid(nodeB):
		nodeBPos = to_local(get_node(get_node_b()).get_global_position())
	var lineWidth = 3.0
	draw_line(nodeAPos, nodeBPos, Color(0, 0.8, 0), lineWidth)
	