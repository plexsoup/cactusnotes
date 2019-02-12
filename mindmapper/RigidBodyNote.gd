"""

This is the base class for all the information about a note. 
It extends RigidBody so it can interact with the physics engine,
but it's primary role is as an information store.

Each RigidBodyNote will have a 'WindowDialog' GUI as a child.

The user interacts through the GUI.
Information is stored here. (Title, Text, ID, etc.)

Question: Should each note maintain it's own list of edges, or is that the job of the edge database?


"""

extends RigidBody2D



# Declare member variables here. Examples:
onready var NoteGUI = get_node("NoteGUI")
onready var global = get_node("/root/global")
var Time = 0


var NoteTitle : String
var NoteText : String
var Pinned : bool = 0
var PinLocation : Vector2
var NoteID : int


signal new_note_requested(nodeRequesting)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(noteTitle: String, noteText: String, pinned : bool, newPosition: Vector2, noteID: int ):
	call_deferred("set_global_position", newPosition)

	if pinned == true:
		set_mode(MODE_STATIC)
	else:
		set_mode(MODE_RIGID)
	
	NoteGUI.start(self, noteTitle, noteText )
	connect("new_note_requested", global.getRootSceneManager().getCurrentScene(), "_on_new_note_requested")

	NoteTitle = noteTitle
	NoteText = noteText
	Pinned = pinned
	PinLocation = newPosition
	NoteID = noteID


func setText(noteText):
	NoteText = noteText

func getText():
	return NoteText
	
func setTitle(noteTitle):
	NoteTitle = noteTitle

func getTitle():
	return NoteTitle

func getPinned():
	print(self.name, " getPinned == ", get_mode())
	print("MODE_STATIC == ", MODE_STATIC)
	print("MODE_RIGID == ", MODE_RIGID)
	if get_mode() == MODE_STATIC:
		return true
	else:
		return false
		

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var width = NoteGUI.get_rect().size.x
	var height = NoteGUI.get_rect().size.y
	NoteGUI.set_global_position(self.get_global_position() - Vector2(width/2, height/2))
	Time += delta
		
func setStatic():
	set_mode(MODE_STATIC)
	$Sprite.set_modulate(Color(1, 0.5, 0))
	
func setRigid():
	set_mode(MODE_RIGID)
	$Sprite.set_modulate(Color(1, 1, 1))

func changeMode(newMode):
	if newMode == MODE_RIGID:
		set_mode(MODE_RIGID)
		apply_central_impulse(Vector2(0.0, 0.0))
	elif newMode == MODE_STATIC:
		set_mode(MODE_STATIC)

func _on_WindowDialog_window_dragged(mouseCoordinates):
	#if get_mode() == MODE_STATIC:
	call_deferred("set_global_position", mouseCoordinates)

func _on_WindowDialog_pinned():
	changeMode(MODE_STATIC)

func _on_WindowDialog_unpinned():
	changeMode(MODE_RIGID)



func _on_NewNodeBTN_pressed():
	print(self.name, "NewNodeBTN_pressed")
	emit_signal("new_note_requested", self)
	