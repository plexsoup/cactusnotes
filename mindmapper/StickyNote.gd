"""

StickyNote handles user interaction with a datastore and an underlying physics object (PhysicsParent).

Note: to move graphNodes around, move the PhysicsParent, not the StickyNote!

"""

extends Node2D

class_name StickyNote

# Declare member variables here. Examples:
enum STATES { idle, dragging, focused }
var CurrentState = STATES.idle

var PINNED : bool = false

var TempPin : bool = false

onready var global = get_node("/root/global")
onready var TextEditBox = $Note/TextEdit
onready var RichTextDisplay = $Note/RichTextLabel
#onready var ColorBG = $Note/TextEdit/ColorRect
onready var PhysicsParent = $".."
var MindMapper

var SaveLoadID

var LastKnownPosition : Vector2
var MinDistanceMoved: float = 100

signal new_note_requested(requestingNode, directionOverride)
signal picked_up_cactus(activeNode)
signal released_cactus()
signal selected_cactus(activeNode)

# Called when the node enters the scene tree for the first time.
func _ready():
	MindMapper = global.getRootSceneManager().getCurrentScene()
	
	TextEditBox.set_text("")
	RichTextDisplay.set_bbcode(TextEditBox.get_text())

	#TextEditBox.hide()
	RichTextDisplay.show()
	
	#ColorBG.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	RichTextDisplay.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

	connect("new_note_requested", global.getRootSceneManager().getCurrentScene(), "_on_flower_new_note_requested")
	connect("picked_up_cactus", global.getCameraFocus(), "_on_picked_up_cactus")
	connect("released_cactus", global.getCameraFocus(), "_on_released_cactus")
	connect("selected_cactus", global.getCameraFocus(), "_on_selected_cactus")

	TextEditBox.grab_focus()
	TextEditBox.select_all()
	
	#Temporary:
	global.getRootSceneManager().getCurrentScene().get_node("CameraFocus").set_global_position(PhysicsParent.get_global_position())
	$Hand.hide()


func start(text : String, pos : Vector2, pinned : bool):
	setState(STATES.idle)
	TextEditBox.set_text(text)
	RichTextDisplay.set_bbcode(TextEditBox.get_text())
	set_global_position(pos)
	if pinned == true:
		PINNED = true
	SaveLoadID = PhysicsParent.get_position_in_parent()

func setPin(pinStatus):
	PINNED = pinStatus
	if PINNED == true:
		PhysicsParent.set_mode(RigidBody.MODE_STATIC)
	else: # PINNED == false
		if TempPin == false:
			PhysicsParent.set_mode(RigidBody.MODE_CHARACTER)

func setState(state):
	CurrentState = state

func setText(text):
	TextEditBox.set_text(text)
	RichTextDisplay.set_bbcode(TextEditBox.get_text())

func setID(id): #Who's setting this?
	SaveLoadID = id

func getID():
	return SaveLoadID

func getSaveData():
	var myInfoDict : Dictionary = { "pos": "Vector2(0,0)", "pinned": false, "ID": 0, "Text": ""}
	
	myInfoDict["pos"] = var2str(get_global_position())
	if PINNED == true:
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
		PINNED = true
	else:
		PhysicsParent.set_mode(RigidBody2D.MODE_CHARACTER)
		setState(STATES.idle)
		PINNED = false
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
	
	RichTextDisplay.hide()
	#TextEditBox.show()
	
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
	#TextEditBox.hide()
	RichTextDisplay.show()

	if PINNED == false:
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
	
	if Input.is_action_just_pressed("drag_note") and CurrentState == STATES.idle:
		setState(STATES.focused)
		emit_signal("selected_cactus", PhysicsParent)
	
	if Input.is_action_pressed("drag_note") and event is InputEventMouseMotion and CurrentState != STATES.dragging:
		setState(STATES.dragging)
		$Hand.show()
		emit_signal("picked_up_cactus", PhysicsParent) # so the camera can follow us
		LastKnownPosition = PhysicsParent.get_global_position()

	if CurrentState == STATES.dragging and Input.is_action_just_released("drag_note"):
		emit_signal("released_cactus")
		$Hand.hide()
		if PhysicsParent.get_global_position().distance_to(LastKnownPosition) > MinDistanceMoved:
			setState(STATES.focused)
			PINNED = true
		
	
#	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note") and CurrentState == STATES.dragging:
#		PhysicsParent.call_deferred("set_global_position", get_global_mouse_position())

#	if TextEditBox.has_focus() and Input.is_action_just_pressed("spawn_note"):
#		emit_signal("new_note_requested", PhysicsParent)
	# moved to CameraFocus
		
func _physics_process(delta):
	if CurrentState == STATES.dragging:
		var currentPos = PhysicsParent.get_global_position()
		var destination = get_global_mouse_position()
		#var offsetVector = (destination - currentPos).normalized() * 50.0
		PhysicsParent.set_global_position(lerp(currentPos, destination, 0.8) )


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
	PINNED = true

