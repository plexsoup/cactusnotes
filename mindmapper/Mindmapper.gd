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

onready var CurrentCamera = get_node("Camera2D")
onready var SaveDialog = get_node("CanvasLayer/SaveDialog")
onready var LoadDialog = get_node("CanvasLayer/LoadDialog")
onready var NotesContainer = get_node("SpawnedNotes")
onready var SpringsContainer = get_node("SpawnedEdges")
onready var FirstNoteSpawnPoint = get_node("FirstNoteSpawnPoint")


var Time : float  = 0
var tmp

func _ready():
	spawnFirstNote()
	
func spawnFirstNote():
	# First Note: to set the stage:
	var noteTitle = "Cactus Notes"
	var noteText = ""
	var pinned = true
	var AttachedTo = FirstNoteSpawnPoint # **** This might be a problem
	var initialPos = FirstNoteSpawnPoint.get_global_position()
	var noteID = 0
	spawnNote(noteTitle, noteText, AttachedTo, pinned, initialPos, noteID )
	
	

	
func spawnNote(title, text, attachedTo, pinned: bool = false, newPosition : Vector2 = Vector2(0, 0), noteID : int = -1):
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
	newSpring.set_node_a(newSpring.get_path_to(nodeA))
	newSpring.set_node_b(newSpring.get_path_to(nodeB))
	newSpring.set_length(750)
	newSpring.set_rest_length(250)
	
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
		


func _on_new_note_requested(requestingNode): # coming from the UI on one of the existing notes
	
	var noteTitle = "New Note"
	var noteText = ""
	var pinned = false
	var attachedTo = requestingNode # **** This might be a problem
	var initialPos = requestingNode.get_global_position() + Vector2(0, -200)
	var noteID = 0
	spawnNote(noteTitle, noteText, attachedTo, pinned, initialPos, noteID )


###################
# Camera settings: disable it when dialogs are open.
###################
func _on_SaveButton_pressed():
	SaveDialog.popup_centered()
	# disable the camera so we can use the scroll wheel
	if CurrentCamera.has_method("disableZoom"):
		CurrentCamera.disableZoom()


func _on_LoadButton_pressed():
	LoadDialog.popup_centered()
	# disable the camera so we can use the scroll wheel
	if CurrentCamera.has_method("disableZoom"):
		CurrentCamera.disableZoom()

func _on_FileDialog_popup_hide():
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()
