"""

This spawns new RigidBodyNotes and spawns DampedSpringJoints to connect them.

Add GraphNodes (as RigidBodyNote) to $SpawnedNotes
Add GraphEdges (as GraphEdge) to $SpawnedEdges

Store no other information about the notes or springs.
You can ask them for the information when you need it, eg: for saving/loading.
	But, maybe another script should handle saving/loading


---
Refactor Notes:
	If you find logic here, that isn't related to spawning, move it to another class

"""



extends Node2D

# Declare member variables here. Examples:

#onready var RigidBodyNote = preload("res://RigidBodyNote.tscn")
onready var GraphEdge = preload("res://GraphEdge.tscn")
onready var NoteGUI = preload("res://NoteGUI.tscn")
onready var NewGraphNodeScene = preload("res://RigidBodyCactus.tscn")

#onready var NotesContainer = get_node("SpawnedNodes")
#onready var SpringsContainer = get_node("SpawnedEdges")
onready var FirstNoteSpawnPoint = get_node("FirstNoteSpawnPoint")

onready var MainCamera = $CameraFocus/Camera2D
onready var CameraFocus = $CameraFocus

onready var GraphNodes = $graphNodes
onready var GraphEdges = $graphEdges

var AnchorNode

var Time : float  = 0
var tmp
var Ticks : int = 0

#var BaseFont

signal camera_drag_requested(mouseCoordinates)
signal node_spawned(node)

func _ready():

	
	connect("camera_drag_requested", MainCamera, "_on_camera_drag_requested")
	connect("camera_drag_requested", CameraFocus, "_on_camera_drag_requested")
	
	connect("node_spawned", CameraFocus, "_on_node_spawned")

	spawnAnchor()

	spawnFirstNote()
	


func spawnAnchor():
	# Temporary while we work out the kinks	
	var anchorNode = StaticBody2D.new()
	#anchorNode.set_mode(RigidBody2D.MODE_STATIC)
	anchorNode.name = "Anchor"
	var collisionShape = CollisionShape2D.new()
	var circleShape = CircleShape2D.new()
	circleShape.set_radius(20)
	collisionShape.set_shape(circleShape)
	add_child(anchorNode)
	anchorNode.set_position(Vector2(0, 0))
	AnchorNode = anchorNode
	return anchorNode

func getAnchorNode():
	return AnchorNode

func spawnFirstNote():
	var firstNode = spawnGraphNode(AnchorNode)
	firstNode.get_node("StickyNote").setText("Type your first [b]big idea[/b] here. Then click the flower.")
	
func getGraphNodeID(node):
	if node.has_node("StickyNote"):
		return node.get_node("StickyNote").getID()
	else:
		#print(self.name, ": error calling getGraphNodeID. ", node, " doesn't have a StickyNote" )
		pass

func spawnGraphSpring(node_a, node_b):
	# Create the Spring
	var newSpring = GraphEdge.instance()
	
	GraphEdges.add_child(newSpring)
	newSpring.start(node_a, node_b)

#	print(self.name, " spawnGraphSpring ", newSpring )
#	print("node_a = ", newSpring.get_node_a(), " == ", newSpring.get_node(newSpring.get_node_a()) )
#	print("node_b = ", newSpring.get_node_b(), " == ", newSpring.get_node(newSpring.get_node_b()))
	
	if node_a is RigidBody2D:
		node_a.set_sleeping(false)
	if node_b is RigidBody2D:
		node_b.set_sleeping(false)
	
	return newSpring
	
func getGraphNodeByID(id):
	#print(self.name, " calling getGraphNodeByID: ", id )
	var result
	if id != null:
		result = GraphNodes.get_child(id)
	else:
		result = AnchorNode
	#print("self.name, getGraphNodeByID: returning ", result)
	return result

func spawnGraphNode(attachedTo):
	#var newGraphNode = RigidBody2D.new()
	
	var newGraphNode = NewGraphNodeScene.instance()
	newGraphNode.set_mode(RigidBody2D.MODE_CHARACTER)
	newGraphNode.set_collision_layer_bit(1, true)
	newGraphNode.set_collision_mask_bit(2, true)
	#newGraphNode.set_mode(RigidBody2D.MODE_STATIC)
	var newCircleShape = CircleShape2D.new()
	newCircleShape.set_radius(75)
	var newCollisionShape = CollisionShape2D.new()
	newCollisionShape.set_shape(newCircleShape)
	var randOffset = Vector2(randf()*300 - 150, randf()*100-300)
	
	var newPos = Vector2(0,0)
	if attachedTo != null:
		newPos = to_local(attachedTo.get_global_position() + randOffset)
	
	newGraphNode.set_global_position(newPos)
	
	
	GraphNodes.add_child(newGraphNode)
	newGraphNode.add_child(newCollisionShape)
	
	var stickyNote = preload("res://StickyNote.tscn")
	var newStickyNote = stickyNote.instance()
	
	newGraphNode.add_child(newStickyNote)
	var newID = GraphNodes.get_child_count()
#	var newID = newGraphNode.get_position_in_parent()
	newStickyNote.setID(newID)
	newGraphNode.set_name("CactusNode-" + str(newID))
	print(self.name, " newGraphNode.name == ", newGraphNode.name)
	#print("New Graph Node: ID == ", newStickyNote.getID())


	newGraphNode.set_sleeping(false)

	if attachedTo != null:
		spawnGraphSpring(newGraphNode, attachedTo)
	
	emit_signal("node_spawned", newGraphNode)
	return newGraphNode



func initializeGraphNode(node, text : String, pos : Vector2 , pinned : bool):
	node.start(text, pos, pinned)


#func spawnNote(title, text, attachedTo, pinned: bool = false, newPosition : Vector2 = Vector2(0, 0), noteID : int = -1):
#	print(self.name, " spawnNote Called" )
#	var newNode = spawnGraphNode(attachedTo)
#	return newNode



func getNewNoteID():
	return GraphNodes.get_child_count()


func getNewEdgeID():
	return GraphEdges.get_child_count()

func getRandomGraphNode():
	return GraphNodes.get_child(randi()%GraphNodes.get_child_count())
	
	

func cleanup():
	# It's important that you remove the edges before you remove the nodes.
	for spring in GraphEdges.get_children():
		GraphEdges.remove_child(spring)
		spring.queue_free()
	for note in GraphNodes.get_children():
		GraphNodes.remove_child(note)
		note.queue_free()



func _physics_process(delta):
	update()



func _draw():
	for spring in GraphEdges.get_children():
		var nodeA = spring.get_node(spring.get_node_a())
		var nodeB = spring.get_node(spring.get_node_b())
		var nodeAPos = Vector2(0,0)
		var nodeBPos = Vector2(0,0)
		if is_instance_valid(nodeA):
			nodeAPos = to_local(nodeA.get_global_position())
		if is_instance_valid(nodeB):
			nodeBPos = to_local(nodeB.get_global_position())
		if is_instance_valid(nodeA) and is_instance_valid(nodeB):
			draw_line(nodeAPos, nodeBPos, Color.burlywood, 3.0, true)


func _on_flower_new_note_requested(requestingNode): # coming from the UI on one of the existing notes
	spawnGraphNode(requestingNode)

func _on_FileIO_new_note_requested(): # When loading notes from file, we don't know the edges yet.
	spawnGraphNode(null)
	
func _on_FileIO_new_spring_requested(node_a_id, node_b_id):
	var node_a
	var node_b
	
	if node_a_id == null:
		node_a = AnchorNode
	else:
		node_a = GraphNodes.get_child(node_a_id)
	if node_b_id == null:
		node_b = AnchorNode
	else:
		node_b = GraphNodes.get_child(node_b_id)
	
	spawnGraphSpring(node_a, node_b)

func _on_TextureRect_gui_input(event):
	#print("textureRect received event: ", event)
	if event is InputEventMouseButton and Input.is_action_just_pressed("drag_camera"):
		#print("user would like to drag the camera view")
		emit_signal("camera_drag_requested")

func _on_cactus_died(cactusNode):
	# find edges connected to Cactus.
	# remove them
	# then queue the cactus free
	# and make sure CameraFocus is aware of the change
	# Raptors already check for dead cacti
	for edge in GraphEdges.get_children():
		# ask the edge if it's connected to node
		if edge.isConnectedTo(cactusNode):
			edge.removeNodeConnection(cactusNode)
			GraphEdges.remove_child(edge)
			edge.queue_free()
			
		#GraphNodes.remove_child(cactusNode)
		#cactusNode.call_deferred("queue_free")
		# Something's not right when we free the cactus.
		

func _on_cleanup_requested():
	cleanup()