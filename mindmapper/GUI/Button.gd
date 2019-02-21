extends TextureButton

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
onready var LeftPanel
export var ButtonName : String
export var args : Array = []

enum STATES { unlocked, locked }
var CurrentState = STATES.unlocked
var MainGUI
var Ticks = 0

signal button_pressed(buttonName, args)

# Called when the node enters the scene tree for the first time.
func _ready():
	if ButtonName == "":
		ButtonName = self.name

	MainGUI = global.getRootSceneManager().getCurrentScene().getMainGUI()
	

func start(signalDestination):
	connect("pressed", self, "_on_button_pressed")
	connect("button_pressed", signalDestination, "_on_GUI_button_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1
	if Ticks % 60 == 0:
		if MainGUI.getState() != MainGUI.STATES.normal and ButtonName.find("Challenge") > -1:
			set_modulate(Color(0.2, 0.2, 0.2))
		else:
			set_modulate(Color.white)


func _on_button_pressed():
	
	if ButtonName.find("Challenge") > -1:
		if MainGUI.getState() == MainGUI.STATES.normal:
			emit_signal("button_pressed", ButtonName, args)
	else:
		emit_signal("button_pressed", ButtonName, args)
	
