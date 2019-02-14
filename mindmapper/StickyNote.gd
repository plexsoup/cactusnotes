extends Node2D

class_name StickyNote

# Declare member variables here. Examples:
enum STATES { idle, dragging, pinned }
var CurrentState = STATES.idle
var TempPin : bool = false

onready var global = get_node("/root/global")
onready var TextEditBox = $TextEdit
onready var RichTextDisplay = $TextEdit/ColorRect/RichTextLabel
onready var ColorBG = $TextEdit/ColorRect
onready var PhysicsParent = $".."

var SaveLoadID

var LastKnownPosition : Vector2
var MinDistanceMoved: float = 100

signal new_note_requested(requestingNode)
signal picked_up_cactus(activeNode)
signal released_cactus()

# Called when the node enters the scene tree for the first time.
func _ready():
	TextEditBox.set_text("")
	RichTextDisplay.set_bbcode(TextEditBox.get_text())
	
	ColorBG.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	RichTextDisplay.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

	connect("new_note_requested", global.getRootSceneManager().getCurrentScene(), "_on_new_note_requested")
	connect("picked_up_cactus", global.getCameraFocus(), "_on_picked_up_cactus")
	connect("released_cactus", global.getCameraFocus(), "_on_released_cactus")

	TextEditBox.grab_focus()
	TextEditBox.select_all()
	
	#Temporary:
	global.getRootSceneManager().getCurrentScene().get_node("CameraFocus").set_global_position(PhysicsParent.get_global_position())

func start(text : String, pos : Vector2, pinned : bool):
	TextEditBox.set_text(text)
	RichTextDisplay.set_bbcode(text)
	set_global_position(pos)
	if pinned == true:
		setState(STATES.pinned)
	else:
		setState(STATES.idle)

func setState(state):
	CurrentState = state

func setID(id): #Who's setting this?
	SaveLoadID = id

func getID():
	return SaveLoadID

func getSaveData():
	var myInfoDict : Dictionary = {}
	
	myInfoDict["pos"] = var2str(get_global_position())
	if CurrentState == STATES.pinned:
		myInfoDict["pinned"] = true
	else:
		myInfoDict["pinned"] = false

	myInfoDict["ID"] = SaveLoadID
	
	myInfoDict["Text"] = TextEditBox.get_text()

	return myInfoDict

func loadSavedData(data : Dictionary):
	var newPos : Vector2 = str2var(data["pos"])
	set_global_position(newPos)
	if bool(data["pinned"]) == true:
		setState(STATES.pinned)
	else:
		setState(STATES.idle)
	SaveLoadID = int(data["ID"])
	TextEditBox.set_text(data["Text"])
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	

		


func _on_TextEdit_mouse_entered():
	ColorBG.hide()
	TempPin = true
	PhysicsParent.set_mode(RigidBody.MODE_STATIC)
	TextEditBox.grab_focus()
	TextEditBox.select_all()
	
func _on_TextEdit_mouse_exited():
	TextEditBox.release_focus()
	TempPin = false
	ColorBG.show()
	if CurrentState != STATES.pinned:
		PhysicsParent.set_mode(RigidBody.MODE_CHARACTER)
	




func _on_TextEdit_text_changed():
	RichTextDisplay.set_bbcode(TextEditBox.get_text())


func _on_TextureButton_pressed():
	emit_signal("new_note_requested", PhysicsParent)


func _on_TextEdit_gui_input(event):
	if Input.is_action_just_pressed("drag_note"):
		setState(STATES.dragging)
		emit_signal("picked_up_cactus", PhysicsParent)
		LastKnownPosition = PhysicsParent.get_global_position()

	if CurrentState == STATES.dragging and Input.is_action_just_released("drag_note"):
		emit_signal("released_cactus")
		if PhysicsParent.get_global_position().distance_to(LastKnownPosition) > MinDistanceMoved:
			setState(STATES.pinned)
		
	
	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note") and CurrentState == STATES.dragging:
		PhysicsParent.set_global_position(get_global_mouse_position())

	if TextEditBox.has_focus() and Input.is_action_just_pressed("spawn_note"):
		emit_signal("new_note_requested", PhysicsParent)
		