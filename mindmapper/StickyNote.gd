extends Sprite

# Declare member variables here. Examples:
enum STATES { idle, dragging, pinned }
var CurrentState = STATES.idle
var TempPin : bool = false

onready var global = get_node("/root/global")
onready var TextEditBox = $TextEdit
onready var RichTextDisplay = $TextEdit/ColorRect/RichTextLabel
onready var ColorBG = $TextEdit/ColorRect
onready var PhysicsParent = $".."

var LastKnownPosition : Vector2
var MinDistanceMoved: float = 100

signal new_note_requested(requestingNode)

# Called when the node enters the scene tree for the first time.
func _ready():
	TextEditBox.set_text("[i]Boo[/i]")
	RichTextDisplay.set_bbcode(TextEditBox.get_text())
	
	ColorBG.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	RichTextDisplay.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

	connect("new_note_requested", global.getRootSceneManager().getCurrentScene(), "_on_new_note_requested")

	TextEditBox.grab_focus()
	TextEditBox.select_all()
	
	#Temporary:
	global.getRootSceneManager().getCurrentScene().get_node("CameraFocus").set_global_position(PhysicsParent.get_global_position())


func setState(state):
	CurrentState = state

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
		LastKnownPosition = PhysicsParent.get_global_position()

	if CurrentState == STATES.dragging and Input.is_action_just_released("drag_note"):
		if PhysicsParent.get_global_position().distance_to(LastKnownPosition) > MinDistanceMoved:
			setState(STATES.pinned)
		
	
	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note") and CurrentState == STATES.dragging:
		PhysicsParent.set_global_position(get_global_mouse_position())

	if TextEditBox.has_focus() and Input.is_action_just_pressed("spawn_note"):
		emit_signal("new_note_requested", PhysicsParent)
		