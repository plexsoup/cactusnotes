"""

StickyNote handles user interaction with a datastore and an underlying physics object (PhysicsParent).

Note: to move graphNodes around, move the PhysicsParent, not the StickyNote!

"""

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
var MindMapper

var SaveLoadID

var LastKnownPosition : Vector2
var MinDistanceMoved: float = 100

signal new_note_requested(requestingNode, directionOverride)
signal picked_up_cactus(activeNode)
signal released_cactus()

# Called when the node enters the scene tree for the first time.
func _ready():
	MindMapper = global.getRootSceneManager().getCurrentScene()
	
	TextEditBox.set_text("")
	RichTextDisplay.set_bbcode(TextEditBox.get_text())
	
	ColorBG.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	RichTextDisplay.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

	connect("new_note_requested", global.getRootSceneManager().getCurrentScene(), "_on_flower_new_note_requested")
	connect("picked_up_cactus", global.getCameraFocus(), "_on_picked_up_cactus")
	connect("released_cactus", global.getCameraFocus(), "_on_released_cactus")

	TextEditBox.grab_focus()
	TextEditBox.select_all()
	
	#Temporary:
	global.getRootSceneManager().getCurrentScene().get_node("CameraFocus").set_global_position(PhysicsParent.get_global_position())

func start(text : String, pos : Vector2, pinned : bool):
	TextEditBox.set_text(text)
	RichTextDisplay.set_bbcode(TextEditBox.get_text())
	set_global_position(pos)
	if pinned == true:
		setState(STATES.pinned)
	else:
		setState(STATES.idle)
	SaveLoadID = PhysicsParent.get_position_in_parent()

func setState(state):
	CurrentState = state
	if state == STATES.pinned:
		PhysicsParent.set_mode(RigidBody.MODE_STATIC)
		#pass
	elif state == STATES.idle:
		PhysicsParent.set_mode(RigidBody.MODE_CHARACTER)
	elif state == STATES.dragging:	
		pass

func setText(text):
	TextEditBox.set_text(text)
	RichTextDisplay.set_bbcode(TextEditBox.get_text())

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

	if SaveLoadID == null:
		SaveLoadID = PhysicsParent.get_position_in_parent()
		#SaveLoadID = MindMapper.get_node("graphNodes").get_position_in_parent(self) # THIS IS A HACK > someone should have set your ID by now!!!
	myInfoDict["ID"] = SaveLoadID
	
	myInfoDict["Text"] = TextEditBox.get_text()

	return myInfoDict

func loadSavedData(data : Dictionary):
	var newPos : Vector2 = str2var(data["pos"])
	PhysicsParent.set_global_position(newPos)
	if bool(data["pinned"]) == true:
		print("loading pin data: ", data["pinned"])
		PhysicsParent.set_mode(RigidBody2D.MODE_STATIC)
		setState(STATES.pinned)
	else:
		PhysicsParent.set_mode(RigidBody2D.MODE_CHARACTER)
		setState(STATES.idle)
	SaveLoadID = data["ID"]
	TextEditBox.set_text(data["Text"])
	RichTextDisplay.set_bbcode(data["Text"])
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()
#
#func _draw():
#
#	var offsetVector = Vector2(-25, 125)
#	draw_string(global.BaseFont, to_local(PhysicsParent.get_global_position()) + offsetVector, PhysicsParent.name, Color.darkgreen)


func enterTextEditMode():
	
	ColorBG.hide()
	TempPin = true
	
	# change the physics mode without changing our pin status
	PhysicsParent.set_mode(RigidBody.MODE_STATIC)
	TextEditBox.grab_focus()
	TextEditBox.select_all()

func exitTextEditMode():
	if is_instance_valid(TextEditBox):
		if TextEditBox.has_focus():
			TextEditBox.release_focus()
	TempPin = false
	ColorBG.show()
	if CurrentState != STATES.pinned:
		PhysicsParent.set_mode(RigidBody.MODE_CHARACTER)
		# print(self.name, " setting PhysicsParent to MODE_CHARACTER")
	PhysicsParent.set_sleeping(false)

func _on_TextEdit_mouse_entered():
	enterTextEditMode()
		
func _on_TextEdit_mouse_exited():
	exitTextEditMode()
	

func _on_TextEdit_text_changed():
	RichTextDisplay.set_bbcode(TextEditBox.get_text())


func _on_TextEdit_gui_input(event):
	if Input.is_action_just_pressed("drag_note"):
		setState(STATES.dragging)
		emit_signal("picked_up_cactus", PhysicsParent) # so the camera can follow us
		LastKnownPosition = PhysicsParent.get_global_position()

	if CurrentState == STATES.dragging and Input.is_action_just_released("drag_note"):
		emit_signal("released_cactus")
		if PhysicsParent.get_global_position().distance_to(LastKnownPosition) > MinDistanceMoved:
			setState(STATES.pinned)
		
	
	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note") and CurrentState == STATES.dragging:
		PhysicsParent.call_deferred("set_global_position", get_global_mouse_position())

#	if TextEditBox.has_focus() and Input.is_action_just_pressed("spawn_note"):
#		emit_signal("new_note_requested", PhysicsParent)
	# moved to CameraFocus
		

func _on_NewNoteButton_pressed():
	emit_signal("new_note_requested", PhysicsParent, null)

func _on_CameraFocus_node_activated():
	enterTextEditMode()
	
func _on_CameraFocus_node_deactivated():
	exitTextEditMode()
	
func _on_new_note_left_pressed():
	emit_signal("new_note_requested", PhysicsParent, Vector2(-1, 0))

func _on_new_note_right_pressed():
	emit_signal("new_note_requested", PhysicsParent, Vector2(1, 0))

func _on_new_note_up_pressed():
	emit_signal("new_note_requested", PhysicsParent, Vector2(0, -1))

func _on_new_note_down_pressed():
	emit_signal("new_note_requested", PhysicsParent, Vector2(0, 1))
	
func _on_MindMapper_node_pin_requested():
	setState(STATES.pinned)

