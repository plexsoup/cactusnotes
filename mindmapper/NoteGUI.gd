"""

This is the GUI interface which allows the user to edit properties of the parent 'RigidBodyNote'

When the scene root or MindMapper need to look up information about a note, they'll ask the parent, not this gui.

There will be fairly tight coupling between the two classes though.

"""


extends WindowDialog

# Declare member variables here. Examples:

enum STATES { note_edit, name_edit, read_only, read_write  }
var CurrentState = STATES.read_write

var TemporaryPin = false

onready var NoteNameBox = $NoteName
onready var NoteTextBox = $NoteContents/NoteText
onready var Overlay = $Overlay
onready var PinIcon = $IconBar/MarginContainer2/PinIcon

var RigidBodyParent

export var InitialTitle : String = "Cactus Note: <unnamed>"
var CurrentTitle = InitialTitle

signal window_dragged(mouseCoordinates)
signal pinned()
signal unpinned()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var minSize = Vector2(200.0, 100.0)
	
	NoteTextBox.set_custom_minimum_size(minSize)
	#NoteTextBox.set_mouse_filter(Control.MOUSE_FILTER_PASS)

func start(rigidBodyNodeToFollow, title, text):
	RigidBodyParent = rigidBodyNodeToFollow
	var connectionError = connect("window_dragged", RigidBodyParent, "_on_NoteGUI_window_dragged")
	if connectionError:
		pass
	#set_title(InitialTitle)
	NoteNameBox.set_text(InitialTitle)

	var closeButton = self.get_close_button()
	closeButton.hide()
	
	print("RigidBodyNote.getPinned() == ", RigidBodyParent.getPinned())
	
	setPinButtonToggle(RigidBodyParent.getPinned())
	
	
	setTitle(title)
	setText(text)
	

	connectionError = connect("pinned", RigidBodyParent, "_on_WindowDialog_pinned")
	connectionError = connect("unpinned", RigidBodyParent, "_on_WindowDialog_unpinned")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#warning-ignore:unused_argument
func _process(delta):
	self.show() # prevent popup dialogs from hiding.
	self.set_global_position($"..".get_global_position())
	# **** it might be better to make your own window dialogs and write code to drag them
		# see: https://www.youtube.com/watch?v=L5QjuFe5Gys

func setReadOnly(value:bool):
	# Mouse Filters: MOUSE_FILTER_PASS, MOUSE_FILTER_STOP, MOUSE_FILTER_IGNORE
	
	if value == true:
		Overlay.show()
		Overlay.set_mouse_filter(Control.MOUSE_FILTER_STOP)
		NoteTextBox.readonly == true
		NoteNameBox.hide()
		CurrentState = STATES.read_only
	elif value == false:
		Overlay.hide()
		NoteNameBox.show()
		NoteTextBox.readonly == false
		Overlay.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		CurrentState = STATES.read_write

func toggleReadOnly():
	if CurrentState == STATES.read_only:
		setReadOnly(false)
	else:
		setReadOnly(true)
	

func setPinButtonToggle(pinned):
	PinIcon.set_pressed(pinned)
	


func editTitle():
	#CurrentState = STATES.name_edit
	#NoteNameBox.show()
	NoteNameBox.grab_focus()
	NoteNameBox.select_all()

func setTitle(title):
	NoteNameBox.set_text(title)
	InitialTitle = title
	CurrentTitle = title
	#self.set_title(title)
	RigidBodyParent.setTitle(title)

func setText(text):
	NoteTextBox.set_text(text)
	RigidBodyParent.setText(text)

	
func hideTitleBox():
	#CurrentState = STATES.note_edit
	#set_size(get_size() - stretchAmount)
	#NoteNameBox.hide()
	NoteNameBox.set_read_only(true)

func _on_TitleIcon_gui_input(event): # user clicked on the ID badge icon

	# show a filename dialog box. make the note title editable
	if event is InputEventMouseButton and event.pressed and Input.is_mouse_button_pressed(BUTTON_LEFT):
		var stretchAmount = Vector2(0, 100.0)
		# we'll show a bunch of fields.. LATER
		
#		if CurrentState != STATES.name_edit:
#			editTitle()
#		else:
#			hideTitleBox()	



func togglePin(): # usually from signal
	if RigidBodyParent.getPinned() == true:
		emit_signal("unpinned")
	else:
		emit_signal("pinned")
	
func pinNote(persistent):
	emit_signal("pinned")
	if persistent == true:
		setPinButtonToggle(true)

func unpinNote(persistent):
	if TemporaryPin == true:
		emit_signal("unpinned")
	else:
		setPinButtonToggle(false)

func _on_NoteText_focus_entered():
	pinNote(false)
	
func engageTempPin():
	pinNote(false)
	
		
#func releaseTempPin():
#	TemporaryPin = false
#	if RigidBodyParent.getPinned() == false:
#		$TempPinTimer.start()
#		yield($TempPinTimer, "timeout") # wait for the timer to finish
#		TemporaryPin = false
#		emit_signal("unpinned")
		
#func _on_NoteText_focus_exited(): # release the temporary pin
#	#unpinNote(false)
#	setReadOnly(true)
#
#func _on_NoteName_focus_exited():
#	#NoteNameBox.hide()
#	#releaseTempPin()
#	setReadOnly(true)
	

func _on_NoteName_focus_entered():
	engageTempPin()


func _on_NoteName_text_entered(new_text):
	CurrentTitle = NoteNameBox.get_text()
	#set_title(CurrentTitle)
	hideTitleBox()




func _on_PinIcon_toggled(button_pressed):
	togglePin()


#func _on_WindowDialog_gui_input(event):
#	# figure out if the user/player is trying to drag the title bar?
#	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note"):
#		# send a signal to the rigid body so it can move
#		emit_signal("window_dragged", get_global_mouse_position())
#
#	if event is InputEventMouseButton and event.doubleclick == true:
#		editTitle()

func processMouseEvents(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note"):
		# send a signal to the rigid body so it can move
		emit_signal("window_dragged", get_global_mouse_position())
		setReadOnly(true)
		setPinButtonToggle(true)
		emit_signal("pinned")

	if event is InputEventMouseButton and event.doubleclick == true:
		setReadOnly(false)
		setPinButtonToggle(true)
		emit_signal("pinned")
	

func _on_Overlay_gui_input(event):
	processMouseEvents(event)

#func _on_NoteGUI_window_dragged(mouseCoordinates):
#	emit_signal("window_dragged", mouseCoordinates)


func _on_NoteGUI_gui_input(event):
	processMouseEvents(event)





#func _on_NoteText_gui_input(event):
#	if event is InputEventMouseButton and event.doubleclick == true:
#		setReadOnly(true)
#
#func _on_NoteName_gui_input(event):
#	if event is InputEventMouseButton and event.doubleclick == true:
#		setReadOnly(true)


func _on_NoteText_mouse_entered():
	pinNote(false)
	
func _on_NoteText_mouse_exited():
	unpinNote(false)
