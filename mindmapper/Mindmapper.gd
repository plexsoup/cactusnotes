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

var BaseFont

signal camera_drag_requested(mouseCoordinates)
signal node_spawned(node)

func _ready():
	establishBaseFont() 
	#spawnFirstNote()



	var anchorNode = spawnAnchor()
	var originalAnchor = anchorNode
	print(self.name, " anchorNode is: ", anchorNode)

	for x in range(1):
		for i in range(1):
			anchorNode = spawnGraphNode(anchorNode)
			
			var newTimer = Timer.new()
			newTimer.set_wait_time(0.5)
			newTimer.set_one_shot(true)
			add_child(newTimer)
			newTimer.start()
			yield(newTimer, "timeout")
			#newTimer.queue_free()

		anchorNode = originalAnchor
	
	print(self.name, " says there should be ", GraphNodes.get_child_count() , " thihngs in GraphNodes" )
	
	connect("camera_drag_requested", MainCamera, "_on_camera_drag_requested")
	connect("camera_drag_requested", CameraFocus, "_on_camera_drag_requested")
	
	connect("node_spawned", CameraFocus, "_on_node_spawned")
	
func establishBaseFont():
	var label = Label.new()
	BaseFont = label.get_font("")
	label.queue_free()
	global.BaseFont = BaseFont

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
	# First Note: to set the stage:
	var noteTitle = "Cactus Notes"
	var noteText = "Click the flower to spawn a new note. Double-click a note to edit the text."
	var pinned = true
	var AttachedTo = FirstNoteSpawnPoint # **** This might be a problem
	var initialPos = FirstNoteSpawnPoint.get_global_position()
	var noteID = 0
	spawnNote(noteTitle, noteText, AttachedTo, pinned, initialPos, noteID )
	
func getGraphNodeID(node):
	if node.has_child("StickyNote"):
		return node.get_node("StickyNote").getID()
	else:
		print(self.name, ": error calling getGraphNodeID. ", node, " doesn't have a StickyNote" )

func spawnGraphSpring(node_a, node_b):
	# Create the Spring
	var newSpring = GraphEdge.instance()
	
	GraphEdges.add_child(newSpring)
	newSpring.start(node_a, node_b)

	
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
	print("New Graph Node: ID == ", newStickyNote.getID())


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

#func _on_BaseCactus_gui_input(event):
#	tmp = event
#	if Input.is_action_just_pressed("spawn_note"):
#		spawnNote("", "", 1, null, null, null )

	
func cleanup():
	# It's important that you remove the edges before you remove the nodes.
	for spring in GraphEdges.get_children():
		spring.queue_free()
	for note in GraphNodes.get_children():
		note.queue_free()

func _physics_process(delta):
	update()

func _draw():
	Ticks += 1
	if Ticks % 200 == 0:
		print(GraphNodes.get_children())
		print(GraphEdges.get_children())
	
#	draw_circle(Vector2(0,0), 50, Color.darkgreen )
##	draw_string(BaseFont, Vector2(0,10), "Vector2(0,0)", Color.blue)
#
#	for graphEdge in GraphEdges.get_children():
#		print("graphEdge == ", graphEdge)
#
#		var node_a_path = graphEdge.get_node_a()
#		var node_b_path = graphEdge.get_node_b()
#		if node_a_path != null and node_b_path != null:
#
#			var node_a_pos : Vector2 = Vector2(0,0)
#			var node_a = graphEdge.get_node(node_a_path)
#			if node_a != null and is_instance_valid(node_a):
#				node_a_pos = node_a.get_position()
#
#			var node_b_pos : Vector2 = Vector2(0,0)
#			var node_b = graphEdge.get_node(node_b_path)
#			if node_b != null and is_instance_valid(node_b):
#				node_b_pos = node_b.get_position()
#
#			draw_line(node_a_pos, node_b_pos, Color.forestgreen, 3.0, true)
#	for graphNode in GraphNodes.get_children():
#
#		if graphNode is RigidBody2D:
#			graphNode.set_sleeping(false)
#
#		var nodePos = Vector2( int(graphNode.get_position().x), int(graphNode.get_position().y))
#		var offset = Vector2(-50, 150)
#
#		#draw_circle(nodePos, 20, Color.whitesmoke)
#
#		var nodeName = graphNode.name
#		draw_string(BaseFont, nodePos + offset, str(nodePos) + " " + nodeName, Color.blueviolet )


func _on_new_note_requested(requestingNode): # coming from the UI on one of the existing notes
	
#	var noteTitle = "New Note"
#	var noteText = ""
#	var pinned = false
#	var attachedTo = requestingNode # **** This might be a problem
#	var initialPos = requestingNode.get_global_position() + Vector2(0, -200)
#	var noteID = 0
	spawnGraphNode(requestingNode)
	#spawnNote(noteTitle, noteText, attachedTo, pinned, initialPos, noteID )





func _on_TextureRect_gui_input(event):
	#print("textureRect received event: ", event)
	if event is InputEventMouseButton and Input.is_action_just_pressed("drag_camera"):
		#print("user would like to drag the camera view")
		emit_signal("camera_drag_requested")
		