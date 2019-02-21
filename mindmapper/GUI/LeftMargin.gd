extends Panel

# Declare member variables here. Examples:
enum STATES { open, closed }
var CurrentState = STATES.closed

var lerpFactor = 0.2

var ClosedPosition : Vector2
var OpenPosition : Vector2

onready var LeftPanel = self
onready var openButton = $OpenPanelButton
onready var MainGUI = $"../.."
onready var global = get_node("/root/global")
var PanelWidth = 78
#var CameraFocus

signal mouse_entered_button_area()

# Called when the node enters the scene tree for the first time.
func _ready():
	ClosedPosition = LeftPanel.get_global_position()
	OpenPosition = LeftPanel.get_global_position() + Vector2(PanelWidth, 0)

	MainGUI = global.getRootSceneManager().getCurrentScene().getMainGUI()
	#CameraFocus = global.getRootSceneManager().getCurrentScene().getCameraFocus()
	initializeButtons()


	
func initializeButtons():
	var buttonContainer = find_node("IconContainer")
	for button in buttonContainer.get_children():
		button.start(MainGUI)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var myPos = LeftPanel.get_global_position()
	if CurrentState == STATES.open:
		LeftPanel.set_global_position(lerp(myPos, OpenPosition, 0.2))
	elif CurrentState == STATES.closed:
		LeftPanel.set_global_position(lerp(myPos, ClosedPosition, 0.2))

func setState(state):
	CurrentState = state

func getState():
	return CurrentState

func _on_OpenPanelButton_pressed():
	if CurrentState == STATES.open:
		setState(STATES.closed)
	else:
		setState(STATES.open)
		

