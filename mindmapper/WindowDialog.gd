extends WindowDialog

# Declare member variables here. Examples:

enum STATES { note_edit, name_edit, read_only  }
var CurrentState = STATES.note_edit

enum PINSTATES { pinned, free }
var CurrentPinState = PINSTATES.free

var TemporaryPin = false
var ID

onready var NoteNameBox = $NoteName
onready var NoteTextBox = $NoteContents/NoteText

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

func start(rigidBodyNodeToFollow, pinStatus, title, text, id):
	RigidBodyParent = rigidBodyNodeToFollow
	var connectionError = connect("window_dragged", RigidBodyParent, "_on_WindowDialog_window_dragged")
	if connectionError:
		pass
	set_title(InitialTitle)
	NoteNameBox.set_text(InitialTitle)

	var closeButton = self.get_close_button()
	closeButton.hide()
	
	changeState(pinStatus)
	setTitle(title)
	setText(text)
	setID(id)
	

	connectionError = connect("pinned", RigidBodyParent, "_on_WindowDialog_pinned")
	connectionError = connect("unpinned", RigidBodyParent, "_on_WindowDialog_unpinned")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#warning-ignore:unused_argument
func _process(delta):
	self.show() # prevent popup dialogs from hiding.
	# **** it might be better to make your own window dialogs and write code to drag them
		# see: https://www.youtube.com/watch?v=L5QjuFe5Gys
	

func editTitle():
	CurrentState = STATES.name_edit
	NoteNameBox.show()
	NoteNameBox.grab_focus()
	NoteNameBox.select_all()

func setTitle(title):
	NoteNameBox.set_text(title)
	InitialTitle = title
	CurrentTitle = title
	self.set_title(title)

func setText(text):
	NoteTextBox.set_text(text)

func setID(id):
	ID = id
	
func hideTitleBox():
	CurrentState = STATES.note_edit
	#set_size(get_size() - stretchAmount)
	NoteNameBox.hide()
	

func _on_TitleIcon_gui_input(event): # user clicked on the ID badge icon

	# show a filename dialog box. make the note title editable
	if event is InputEventMouseButton and event.pressed and Input.is_mouse_button_pressed(BUTTON_LEFT):
		var stretchAmount = Vector2(0, 100.0)

		if CurrentState != STATES.name_edit:
			editTitle()
		else:
			hideTitleBox()	





func changeState(pinState):
	CurrentPinState = pinState
	
	if CurrentPinState == PINSTATES.free:
		PinIcon.set_modulate(Color(1, 1, 1))
		emit_signal("unpinned")
	else:
		PinIcon.set_modulate(Color(1, 0.5, 0.0))
		emit_signal("pinned")
		

func _on_PinIcon_gui_input(event):
	if event is InputEventMouseButton and event.pressed and Input.is_mouse_button_pressed(BUTTON_LEFT):
		# change your parent's rigid body to a static body
#		if $"..".has_method("changeMode"):
#			$"..".changeMode()
		if CurrentPinState == PINSTATES.pinned:
			changeState(PINSTATES.free)
		elif CurrentPinState == PINSTATES.free:
			changeState(PINSTATES.pinned)
			





func _on_WindowDialog_gui_input(event):
	# figure out if the user/player is trying to drag the title bar?
	if event is InputEventMouseMotion and Input.is_action_pressed("drag_note"):
		# send a signal to the rigid body so it can move
		emit_signal("window_dragged", get_global_mouse_position())

	if event is InputEventMouseButton and event.doubleclick == true:
		editTitle()
		


func _on_NoteText_focus_entered():
	TemporaryPin = true
	emit_signal("pinned")
	

func _on_NoteText_focus_exited():
	TemporaryPin = false
	if CurrentPinState == PINSTATES.free:
		$TempPinTimer.start()
		
func _on_NoteName_focus_exited():
	NoteNameBox.hide()
	if CurrentPinState == PINSTATES.free:
		$TempPinTimer.start()


func _on_TempPinTimer_timeout():
	if CurrentPinState == PINSTATES.free:
		TemporaryPin = false
		emit_signal("unpinned")


func _on_NoteName_focus_entered():
	TemporaryPin = true
	emit_signal("pinned")

#func _on_NoteName_text_changed():
#	CurrentTitle = NoteNameBox.get_text()
#	set_title(CurrentTitle)

func _on_NoteName_text_entered(new_text):
	CurrentTitle = NoteNameBox.get_text()
	set_title(CurrentTitle)
	hideTitleBox()
