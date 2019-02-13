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

onready var NotesContainer = get_node("SpawnedNotes")
onready var SpringsContainer = get_node("SpawnedEdges")
onready var FirstNoteSpawnPoint = get_node("FirstNoteSpawnPoint")

onready var MainCamera = $CameraFocus/Camera2D

onready var GraphNodes = $graphNodes
onready var GraphEdges = $graphEdges


var Time : float  = 0
var tmp

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
	connect("node_spawned", MainCamera, "_on_node_spawned")
	
func establishBaseFont():
	var label = Label.new()
	BaseFont = label.get_font("")
	label.queue_free()

func spawnAnchor():
	# Temporary while we work out the kinks	
	var anchorNode = StaticBody2D.new()
	#anchorNode.set_mode(RigidBody2D.MODE_STATIC)
	anchorNode.name = "Anchor"
	var collisionShape = CollisionShape2D.new()
	var circleShape = CircleShape2D.new()
	circleShape.set_radius(20)
	collisionShape.set_shape(circleShape)
	GraphNodes.add_child(anchorNode)
	anchorNode.set_global_position(Vector2(200, 200))
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
	
	

func spawnGraphSpring(node_a, node_b):
	# Create the Spring
	var newSpring = DampedSpringJoint2D.new()
	GraphEdges.add_child(newSpring)

	newSpring.set_node_a(newSpring.get_path_to(node_a))
	newSpring.set_node_b(newSpring.get_path_to(node_b))
	
	newSpring.set_length(250)
	newSpring.set_rest_length(150)
	newSpring.set_stiffness(200)
	newSpring.set_damping(1)
	

func spawnGraphNode(attachedTo):
	var newGraphNode = RigidBody2D.new()
	newGraphNode.set_mode(RigidBody2D.MODE_CHARACTER)
	var newCircleShape = CircleShape2D.new()
	newCircleShape.set_radius(75)
	var newCollisionShape = CollisionShape2D.new()
	newCollisionShape.set_shape(newCircleShape)
	newGraphNode.set_global_position(attachedTo.get_global_position() - Vector2(0, 200))
	GraphNodes.add_child(newGraphNode)
	newGraphNode.add_child(newCollisionShape)

#	var spriteTexture = preload("res://icon.png")
#	var newSprite = Sprite.new()

	#var newNoteGUI = NoteGUI.instance()
	
	var stickyNote = preload("res://StickyNote.tscn")
	var newStickyNote = stickyNote.instance()
	
	newGraphNode.add_child(newStickyNote)


	newGraphNode.set_sleeping(false)
	spawnGraphSpring(newGraphNode, attachedTo)
	
	emit_signal("node_spawned", newGraphNode)
	return newGraphNode


func spawnNote(title, text, attachedTo, pinned: bool = false, newPosition : Vector2 = Vector2(0, 0), noteID : int = -1):
	var newNode = spawnGraphNode(attachedTo)
	return newNode
	
func OLDspawnNote(title, text, attachedTo, pinned: bool = false, newPosition : Vector2 = Vector2(0, 0), noteID : int = -1):
	# newPosition seems unnecessary, but it's required for when we load notes from the save-file
	
	if noteID == null:
		noteID = getNewNoteID()
	
	var newNote = RigidBodyNote.instance()

	if newPosition == null:
		newPosition = attachedTo.get_global_position() + Vector2(randf()*400-200, -200)

	NotesContainer.add_child(newNote)

	if attachedTo != FirstNoteSpawnPoint and attachedTo != null: # don't spawn an edge for the first node
		spawnEdge(newNote, attachedTo)
		

	newNote.start(title, text, pinned, newPosition, noteID)

func spawnEdge(nodeA, nodeB):
	var newSpring = GraphEdge.instance()
	
	SpringsContainer.add_child(newSpring)
	#nodeA.add_child(newSpring)
	newSpring.set_global_position(nodeA.get_global_position())
	newSpring.set_node_a(newSpring.get_path_to(nodeA))
	newSpring.set_node_b(newSpring.get_path_to(nodeB))
	newSpring.set_length(750)
	newSpring.set_rest_length(350)
	
func getNewNoteID():
	return NotesContainer.get_child_count()

func getNewEdgeID():
	return SpringsContainer.get_child_count()

#func _on_BaseCactus_gui_input(event):
#	tmp = event
#	if Input.is_action_just_pressed("spawn_note"):
#		spawnNote("", "", 1, null, null, null )

	
func cleanup():
	for note in NotesContainer.get_children():
		note.queue_free()
	for spring in SpringsContainer.get_children():
		spring.queue_free()
		

func _physics_process(delta):
	update()

func _draw():
	for graphEdge in GraphEdges.get_children():
		var node_a_pos = graphEdge.get_node(graphEdge.get_node_a()).get_position()
		var node_b_pos = graphEdge.get_node(graphEdge.get_node_b()).get_position()
		draw_line(node_a_pos, node_b_pos, Color(0.2, 0.2, 0.2), 3.0, true)
	for graphNode in GraphNodes.get_children():
		
		if graphNode is RigidBody2D:
			graphNode.set_sleeping(false)
		draw_circle(graphNode.get_position(), 20, Color(0, 1, 1))
		
		var nodePos = Vector2( int(graphNode.get_position().x), int(graphNode.get_position().y))
		var nodeName = graphNode.name
		draw_string(BaseFont, graphNode.get_position(), str(nodePos) + " " + nodeName, Color(1, 0, 1) )


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
		print("user would like to drag the camera view")
		emit_signal("camera_drag_requested")
		