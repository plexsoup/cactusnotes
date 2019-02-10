extends Node2D

# Declare member variables here. Examples:
onready var RigidBodyNote = preload("res://RigidBodyNote.tscn")
onready var BaseCactus = get_node("BaseCactusSB")
onready var CurrentCamera = get_node("Camera2D")
onready var SaveDialog = get_node("CanvasLayer/SaveDialog")
onready var LoadDialog = get_node("CanvasLayer/LoadDialog")
onready var NotesContainer = get_node("SpawnedNotes")
onready var SpringsContainer = get_node("Springs")

var Time : float  = 0
var tmp

func _ready():
	pass
	
#func getVelocityVector(delta):
#	var springDistance = 200.0
#	return Vector2(0.0, 0.0)
	

func _physics_process(delta):
	update()
	Time += delta
	
func _draw():
	for spring in SpringsContainer.get_children():
		var nodeA = spring.get_node(spring.get_node_a())
		var nodeAPos = nodeA.get_position()
		
		var nodeB = spring.get_node(spring.get_node_b())
		var nodeBPos = to_local(nodeB.get_global_position())
		var lineColor = Color(0, 0.8, 0.2)
		var lineWidth = 3.0
		var antialias = true
		draw_line(nodeAPos, nodeBPos, lineColor, lineWidth, antialias)
		
		draw_circle(nodeAPos, 20, Color(0, 1, 0))
		
	
	
func spawnNote(id, title, text, pinStatus, newPosition):
	print("trying to spawn a note")
	# spawn a new note, pinned to the cactus.
	var newNote = RigidBodyNote.instance()
	var randX = randf()*400 - 200
	NotesContainer.add_child(newNote)
	newNote.start(newPosition, pinStatus, title, text, id)
	
	var newSpring = DampedSpringJoint2D.new()
	SpringsContainer.add_child(newSpring)
	newSpring.set_node_a(newSpring.get_path_to(BaseCactus))
	newSpring.set_node_b(newSpring.get_path_to(newNote))
	newSpring.set_length(750)
	newSpring.set_rest_length(250)
	
	

func _on_BaseCactus_gui_input(event):
	tmp = event
	if Input.is_action_just_pressed("spawn_note"):
		spawnNote(null, "", "", 1, null)




func _on_FileDialog_popup_hide():
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()
	

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


func _on_SaveDialog_file_selected(path):
	print(path)

	var f = File.new()
	
	f.open(path, File.WRITE)
	
	var noteID = 0
	var completeNotesDict : Dictionary = {}
	
	for note in $SpawnedNotes.get_children():
		# read the title, the note, the pin status, and the coordinates
		# then write to a file
		var currentNoteDict : Dictionary = {}	

		var noteContainer = note.get_node("WindowDialog")
		var noteTitle = note.get_node("WindowDialog/NoteName").get_text()
		var noteText = note.get_node("WindowDialog/NoteContents/NoteText").get_text()

		currentNoteDict["ID"] = noteID
		currentNoteDict["Title"] = noteTitle
		currentNoteDict["Text"] = noteText
		currentNoteDict["PinMode"] = noteContainer.CurrentPinState
		currentNoteDict["Position"] = note.get_global_position()

		#notesArr.push_back(currentNoteDict)

		completeNotesDict[noteID] = currentNoteDict
		
		noteID += 1
	
	var jsonString = to_json(completeNotesDict)
	f.store_string(jsonString)

	print(jsonString)

	
	f.close()
	
		
	
func cleanup():
	for note in NotesContainer.get_children():
		note.queue_free()
	for spring in SpringsContainer.get_children():
		spring.queue_free()	

func _on_LoadDialog_file_selected(path):
	# open a JSON file. read each object and convert into a note.
	cleanup()
	
	print(path)
	var f = File.new()
	f.open(path, File.READ)

	# BUG: Fix loading json. 
	# Seems like I'm only getting one record.
	# Do i have to loop over every line?
	print("File text: ", f.get_as_text())
	var notesDict : Dictionary = parse_json(f.get_as_text())
	print("notesDict: ", notesDict)

	f.close()
	
	for row in notesDict:
		var note = notesDict[row]
		spawnNote(note["ID"], note["Title"], note["Text"], note["PinMode"], note["Position"])
	
	#print(nodeDict)
	
	
	





