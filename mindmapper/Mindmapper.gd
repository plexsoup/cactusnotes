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
onready var RigidBodyNote = preload("res://RigidBodyNote.tscn")
onready var GraphEdge = preload("res://GraphEdge.tscn")
onready var NoteGUI = preload("res://NoteGUI.tscn")

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


func spawnFirstNote():
	spawnGraphNode(AnchorNode)
	
func getGraphNodeID(node):
	if node.has_node("StickyNote"):
		return node.get_node("StickyNote").getID()
	else:
		print(self.name, ": error calling getGraphNodeID. ", node, " doesn't have a StickyNote" )

func spawnGraphSpring(node_a, node_b):
	# Create the Spring
	var newSpring = GraphEdge.instance()
	
	GraphEdges.add_child(newSpring)
	newSpring.start(node_a, node_b)

	print(self.name, " spawnGraphSpring ", newSpring )
	print("node_a = ", newSpring.get_node_a(), " == ", newSpring.get_node(newSpring.get_node_a()) )
	print("node_b = ", newSpring.get_node_b(), " == ", newSpring.get_node(newSpring.get_node_b()))
	
	if node_a is RigidBody2D:
		node_a.set_sleeping(false)
	if node_b is RigidBody2D:
		node_b.set_sleeping(false)
	
	return newSpring
	
func getGraphNodeByID(id):
	if id != null:
		return GraphNodes.get_child(id)
	else:
		return AnchorNode
	# For saving and loading games, this assumes that you've reinstated them in the same order as before.

func spawnGraphNode(attachedTo):
	var newGraphNode = RigidBody2D.new()
	newGraphNode.set_mode(RigidBody2D.MODE_CHARACTER)
	var newCircleShape = CircleShape2D.new()
	newCircleShape.set_radius(75)
	var newCollisionShape = CollisionShape2D.new()
	newCollisionShape.set_shape(newCircleShape)
	var randOffset = Vector2(randf()*300 - 150, randf()*100-300)
	
	if attachedTo != null:
		newGraphNode.set_position(attachedTo.get_position() + randOffset)
	
	GraphNodes.add_child(newGraphNode)
	newGraphNode.add_child(newCollisionShape)
	
	var stickyNote = preload("res://StickyNote.tscn")
	var newStickyNote = stickyNote.instance()
	
	newGraphNode.add_child(newStickyNote)

	newStickyNote.setID(newGraphNode.get_position_in_parent())
	#print("New Graph Node: ID == ", newStickyNote.getID())


	newGraphNode.set_sleeping(false)

	if attachedTo != null:
		spawnGraphSpring(newGraphNode, attachedTo)
	
	emit_signal("node_spawned", newGraphNode)
	return newGraphNode



func initializeGraphNode(node, text : String, pos : Vector2 , pinned : bool):
	node.start(text, pos, pinned)


func spawnNote(title, text, attachedTo, pinned: bool = false, newPosition : Vector2 = Vector2(0, 0), noteID : int = -1):
	print(self.name, " spawnNote Called" )
	var newNode = spawnGraphNode(attachedTo)
	return newNode



func getNewNoteID():
	return GraphNodes.get_child_count()


func getNewEdgeID():
	return GraphEdges.get_child_count()



func cleanup():
	# It's important that you remove the edges before you remove the nodes.
	for spring in GraphEdges.get_children():
		spring.queue_free()
	for note in GraphNodes.get_children():
		note.queue_free()



#func _physics_process(delta):
#	update()



#func _draw():
#	Ticks += 1
#	if Ticks % 200 == 0:
#		print(self.name, " GraphNodes.children: ", GraphNodes.get_children())
#		print(self.name, " GraphEdges.children: ", GraphEdges.get_children())



func _on_new_note_requested(requestingNode): # coming from the UI on one of the existing notes
	spawnGraphNode(requestingNode)



func _on_TextureRect_gui_input(event):
	#print("textureRect received event: ", event)
	if event is InputEventMouseButton and Input.is_action_just_pressed("drag_camera"):
		#print("user would like to drag the camera view")
		emit_signal("camera_drag_requested")
		