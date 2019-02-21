"""

This holds all the interface elements and user interaction for the main scene (note creation)



"""

extends Node2D

var Ticks = 0

onready var CurrentCamera = get_node("../CameraFocus/Camera2D")
onready var CameraFocus = get_node("../CameraFocus")

onready var SaveDialog = get_node("CanvasLayer/SaveDialog")
onready var LoadDialog = get_node("CanvasLayer/LoadDialog")
onready var EscDialog = get_node("CanvasLayer/EscDialog")
onready var ChallengeDialog = get_node("CanvasLayer/Challenge")
onready var FileIO = get_node("FileIO")

var ScreenSize

signal dialog_box_popup()
signal dialog_box_closed()
signal mouse_entered_button_area()
signal mouse_exited_button_area()
signal challenge_ended()

var MouseProtectedAreaActivated : bool

enum STATES {
	normal, time_challenge, defense_challenge
}
var CurrentState = STATES.normal

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("dialog_box_popup", CameraFocus, "_on_dialog_box_popup")
	connect("dialog_box_closed", CameraFocus, "_on_dialog_box_closed")
	connect("mouse_entered_button_area", CameraFocus, "_on_mainGUI_mouse_entered_button_area")
	connect("mouse_exited_button_area", CameraFocus, "_on_mainGUI_mouse_exited_button_area")

	connect("challenge_ended", ChallengeDialog, "_on_challenge_ended")

	hideDialogs()

	ScreenSize = get_viewport_rect().size
	print(self.name, ": ScreenSize == ", ScreenSize)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	Ticks += 1
	
	# Count remaining Raptors
	if Ticks%20 == 0:
		if CurrentState == STATES.defense_challenge and getNumRaptors() == 0:
			endDefenseChallenge()

	testMouseProtectedZones()

func testMouseProtectedZones():

		
	var mousePos = get_viewport().get_mouse_position()

#	if Ticks % 10 == 0:
#		print(self.name, " mousePos == ", mousePos)
	var LeftMargin = $CanvasLayer/LeftMargin
	var marginWidth = 64
	if LeftMargin.getState() == LeftMargin.STATES.open:
		if mousePos.x < marginWidth and MouseProtectedAreaActivated == false:
			MouseProtectedAreaActivated = true
			print(self.name, "entered")
			emit_signal("mouse_entered_button_area")
		elif mousePos.x > marginWidth and MouseProtectedAreaActivated == true:
			MouseProtectedAreaActivated = false
			print(self.name, "exited")
			emit_signal("mouse_exited_button_area")
	elif LeftMargin.getState() == LeftMargin.STATES.closed:
		if MouseProtectedAreaActivated == true:
			MouseProtectedAreaActivated = false
			print(self.name, "exited")
			emit_signal("mouse_exited_button_area")
			
			
func hideDialogs():
	$CanvasLayer/EscDialog.hide()
	
	ChallengeDialog.hide()
	

func spawnDialogBox(textArray):
	var DialogBoxContainer = get_node("DialogBoxes")

	for box in DialogBoxContainer.get_children():
		box.queue_free()
	
	emit_signal("dialog_box_popup")
	var dialogBoxScene = preload("res://DialogBox.tscn")
	var newDialogBox = dialogBoxScene.instance()
	DialogBoxContainer.add_child(newDialogBox)
	
	newDialogBox.start(textArray, self)

###################
# Camera settings: disable it when dialogs are open.
###################
func _on_SaveButton_pressed():
	emit_signal("dialog_box_popup")
	SaveDialog.popup_centered()
	# disable the camera so we can use the scroll wheel
	if CurrentCamera.has_method("disableZoom"):
		CurrentCamera.disableZoom()


func _on_LoadButton_pressed():
	emit_signal("dialog_box_popup")
	LoadDialog.popup_centered()
	# disable the camera so we can use the scroll wheel
	if CurrentCamera.has_method("disableZoom"):
		CurrentCamera.disableZoom()
	# disable the avatar so we're not accidentally scrolling across the map
	



func _on_HelpButton_pressed():
	var DialogTextArr = [
		"Click and drag to move a note. Use the mouse to direct the magnifying glass. \n\nClick a flower to spawn a new note.\n\nIf the magnifying glass is locked onto a note, you can click on any empty space to free it.",
		"You may also navigate and create notes with the keyboard. shift + arrow keys to move around. ctrl + arrow keys to create new notes."
	]
	spawnDialogBox(DialogTextArr)

func _on_DialogBox_completed():
	emit_signal("dialog_box_closed")

func _input(event):
	if Input.is_action_just_pressed("show_escape_dialog"):
		if EscDialog.is_visible() == false:
			EscDialog.show()
			emit_signal("dialog_box_popup")
		else:
			EscDialog.hide()
			emit_signal("dialog_box_closed")
	

func _on_Background_gui_input(event):
	if event is InputEventMouseButton:
		# print("clicked on the canvas")
		pass
		
	elif event is InputEventMouseMotion and Input.is_action_pressed("drag_camera"):
		# send a signal to the rigid body so it can move
		emit_signal("window_dragged", get_global_mouse_position())


func _on_AboutCactusNotesButton_button_pressed():
	var DialogTextArr = [
		"Cactus Notes is a mindmapping / brainstorming application developed for the Sixth Godot Wild Game Jam. It was intended as a replacement for paper and whiteboards, for use in the Game Design planning process...",
		"... at least, that was the intention. It turns out it's also a great for building conspiracy walls. Red yarn will come in a future DLC.",
		"Source code is available at [url]https://github.com/plexsoup/[/url]",
		"Thanks for trying it!"
	]
	spawnDialogBox(DialogTextArr)




func _on_SaveDialog_popup_hide():
	#print("save dialog popup hidden")
	emit_signal("dialog_box_closed")
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()



func _on_LoadDialog_popup_hide():
	#print("load dialog popup hidden")
	emit_signal("dialog_box_closed")
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()


func _on_TimedChallengeTimer_timeout():
	var textArr = [
		"Thus ends the timed challenge.",
		"Let's hope it was productive, and fun.",
		"If you generated some ideas, consider defending them in a raptor challenge next."
	]
	spawnDialogBox(textArr)
	$CanvasLayer/TimeChallengeButton/TimedChallengeTimer/TimerCountdown.hide()
	$"CanvasLayer/TimeChallengeButton/Warning Label".hide()

func _on_TimeChallengeButton_pressed():
	# print(self.name, " opening time challenge dialog")
#	var time = $CanvasLayer/TimeChallengeButton/TimedChallengeTimer.get_wait_time()
	
	var duration = 60
	var instructions = "It's said that time pressure can stimulate creativity. \nCome up with a project or concept you need to brainstorm. \nYou have " + str(duration) + " seconds to generate as many ideas as possible."
	var challengeType = "time"
	var completionTextArr = ["Thus ends the timed challenge. Hopefully it was productive."]
	ChallengeDialog.start(challengeType, instructions, duration, completionTextArr)
	
	emit_signal("dialog_box_popup")
	


func spawnRaptor():
	var minDistance = 500
	var maxDistance = 5000
	var distRange = maxDistance - minDistance
	var randDistance = randf()*distRange + minDistance

	var raptor = preload("res://enemies/Raptor.tscn")
	var newRaptor = raptor.instance()
	newRaptor.set_position(to_local(CameraFocus.get_global_position() + Vector2(randDistance, 0).rotated(randf()*2*PI)))
	$Raptors.add_child(newRaptor)

func getNumRaptors():
	return $Raptors.get_child_count()


func _on_DefenseChallengeButton_pressed():
	var instructions = "Forced to actively defend your ideas from external threat, you might learn which are most important to you... Bring on the raptors!"
	var challengeType = "raptor"
	var duration : float = 60
	var completionTextArr = ["Thus ends the raptor challenge. Hopefully some of your work survived."]
	ChallengeDialog.start(challengeType, instructions, duration, completionTextArr)
	emit_signal("dialog_box_popup")

func setState(state):
	CurrentState = state
	
func getState():
	return CurrentState
	
func endDefenseChallenge():
	var textArr = ["Thus ends the defense challenge. Hopefully your ideas survived."]
	spawnDialogBox(textArr)
	setState(STATES.normal)
	emit_signal("challenge_ended")
	
func _on_DefenseChallengeDurationTimer_timeout():
	endDefenseChallenge()









func spawnRaptors():
	var numRaptors = 60
	for i in range(numRaptors):
		
		global.wait(0.075)
		spawnRaptor()

func cleanupRaptors():
	for raptor in $Raptors.get_children():
		raptor.queue_free()
		

#func _on_DefenseDialog_ReturnButton_pressed():
#	DefenseDialog.hide()
#	emit_signal("dialog_box_closed")


func _on_QuitButton_pressed():
	get_tree().quit()
	
func _on_ResumeButton_pressed():
	$CanvasLayer/EscDialog.hide()

func _on_OpenPanelButton_pressed():
	$LeftMargin/LeftPanel.show()

func _on_GUI_button_pressed(buttonName, args):
	#print(self.name, " _on_GUI_button_pressed(", buttonName, " , ", args )
	match buttonName:
		"Save":
			_on_SaveButton_pressed()
		"Load":
			_on_LoadButton_pressed()
		"Help":
			_on_HelpButton_pressed()
		"RaptorChallenge":
			_on_DefenseChallengeButton_pressed()
		"TimeChallenge":
			_on_TimeChallengeButton_pressed()
		"About":
			_on_AboutCactusNotesButton_button_pressed()

func _on_AboutCactusNotesButton_pressed():
	pass # Replace with function body.

func _on_Challenge_started(challengeType):
	# print(self.name, " _on_challenge_started(", challengeType , ")")
	match challengeType:
		"raptor":
			setState(STATES.defense_challenge)
			spawnRaptors()
		"time":
			setState(STATES.time_challenge)
			pass

func _on_Challenge_completed(challengeType):
	match challengeType:
		"raptor":
			setState(STATES.normal)
			cleanupRaptors()
		"time":
			setState(STATES.normal)
			pass






