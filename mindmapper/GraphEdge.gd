"""

GraphEdge is an edge between two graph nodes (RigidBodyNotes).

It should store a reference to each RigidBodyNote it's connected to, including their IDs for the JSON datastore.


"""

extends DampedSpringJoint2D

enum STATES { alive, dead }
var CurrentState = STATES.alive

onready var global = get_node("/root/global")
var MindMapper

var Node_A_ID
var Node_B_ID

var Ticks = 0

signal edge_connected()
signal edge_disconnected()

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

	alertStickyNote(nodeA, "connected")
	alertStickyNote(nodeB, "connected")

func die():
	if CurrentState == STATES.alive: # you can only die once
		var nodeA = get_node(get_node_a())
		var nodeB = get_node(get_node_b())
		
		alertStickyNote(nodeA, "disconnected")
		set_node_a("")
		alertStickyNote(nodeB, "disconnected")
		set_node_b("")
	
		$"..".remove_child(self)
		call_deferred("queue_free")
	CurrentState = STATES.dead
	

func alertStickyNote(node, action):
	if action == "connected":
		if node != null and node.has_node("StickyNote"):
			connect("edge_connected", node.get_node("StickyNote"), "_on_edge_connected")
			emit_signal("edge_connected")
			disconnect("edge_connected", node.get_node("StickyNote"), "_on_edge_connected")
	elif action == "disconnected":
		if node != null and node.has_node("StickyNote"):
			print("disconnecting")
			connect("edge_disconnected", node.get_node("StickyNote"), "_on_edge_disconnected")
			emit_signal("edge_disconnected")
			disconnect("edge_disconnected", node.get_node("StickyNote"), "_on_edge_disconnected")
		
		
		
func isConnectedTo(node):
	if get_node(get_node_a()) == node or get_node(get_node_b()) == node:
		return true
	else:
		return false

func removeNodeConnection(node):
	if node.has_node("StickyNote"):
		connect("edge_disconnected", node.get_node("StickyNote"), "_on_edge_disconnected")

	if get_node(get_node_a()) == node:
		set_node_a("")
		if node.has_node("StickyNote"):
			emit_signal("edge_disconnected")
	if get_node(get_node_b()) == node:
		set_node_b("")
		if node.has_node("StickyNote"):
			emit_signal("edge_disconnected")
	if node.has_node("StickyNote"):
		disconnect("edge_disconnected", node.get_node("StickyNote"), "_on_edge_disconnected")

	
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
	