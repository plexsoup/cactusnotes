"""
DialogBox displays a succession of text strings from an array.
Individual letters are revealed with keystroke audio on a timer timeout.

SceneTree should look like this:
	DialogBox : Node2D
	DialogTextBox : TextEdit
	KeypressNoise : AudioStream
	DialogTextLabel : Label
		LetterTimer : Timer


"""

extends Control

# Declare member variables here. Examples:
export var DialogText : Array  = [""]

onready var LetterTimer = $DialogTextLabel/LetterTimer
onready var DialogBox = $DialogTextBox
onready var KeypressAudio = $KeypressNoise

var CurrentLine = 0
var DisplayedText = ""
var CurrentLineText = ""
var NumLettersDisplayed : int = 0

#var NodeToFollow

signal initialized
signal completed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(textArray : Array, parentScene):
	DialogText = textArray
		
	#connect("initialized", global.getCurrentPlayer(), "_on_dialogBox_initialized")
	connect("completed", parentScene, "_on_DialogBox_completed")

	DisplayedText = ""
	if DialogText.size() > 0:
		CurrentLineText = DialogText[0]
	else:
		end() # quit if there's no text to show
	LetterTimer.start()
	#NodeToFollow = nodeToFollow
	#DialogBox.set_wrap_enabled(true)
	DialogBox.set_bbcode(CurrentLineText)
	DialogBox.set_visible_characters(0)
	#DialogBox.set_position(newPosition)

	#emit_signal("initialized")
	
func end():
	emit_signal("completed")

	queue_free()

func showNextLine():
	CurrentLine += 1
	NumLettersDisplayed = 0
	if CurrentLine >= DialogText.size():
		end()
	else:
		CurrentLineText = DialogText[CurrentLine]
		DialogBox.set_bbcode(CurrentLineText)
		DialogBox.set_visible_characters(NumLettersDisplayed)
		LetterTimer.start()
		


func showNextLetter():
	if NumLettersDisplayed < CurrentLineText.length():
		LetterTimer.start()


		NumLettersDisplayed += 1
		KeypressAudio.play()
		
		
	DialogBox.set_visible_characters(NumLettersDisplayed)
	#DialogBox.set_text(CurrentLineText.left(NumLettersDisplayed))

func revealAllLettersOrShowNextLine():
	if NumLettersDisplayed < CurrentLineText.length(): # show the whole message
		NumLettersDisplayed = CurrentLineText.length()
	else: # show the next line
		showNextLine()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		end()
	
#	if is_instance_valid(NodeToFollow):
#		set_global_position(NodeToFollow.get_global_position() + Vector2(0, -200))
	if Input.is_action_just_pressed("ui_accept"):
		revealAllLettersOrShowNextLine()



func _on_LetterTimer_timeout():
	showNextLetter()



# allow the user to left-click on the dialog box to proceed.
# (but not mouse-wheel!)
func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			revealAllLettersOrShowNextLine()


func _on_DialogTextBox_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			revealAllLettersOrShowNextLine()
			

func _on_DialogTextBox_meta_clicked(meta):
	#HMM. The gui_input click to skip through text seems to interfere with the meta-clicked
	print(self.name, " clicked on URL", meta)
	pass
	#OS.shell_open(meta);
	#OS.shell_execute("https://www.github.com/plexsoup");
