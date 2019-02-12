"""

GraphEdge is an edge between two graph nodes (RigidBodyNotes).

It should store a reference to each RigidBodyNote it's connected to, including their IDs for the JSON datastore.


"""

extends DampedSpringJoint2D

# Declare member variables here. Examples:
var Node_A_ID
var Node_B_ID

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(nodeAID, nodeBID):
	Node_A_ID = nodeAID
	Node_B_ID = nodeBID
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _draw():
	var nodeAPos = to_local(get_node(get_node_a()).get_global_position())
	var nodeBPos = to_local(get_node(get_node_b()).get_global_position())
	var lineWidth = 3.0
	draw_line(nodeAPos, nodeBPos, Color(0, 0.8, 0), lineWidth)
	