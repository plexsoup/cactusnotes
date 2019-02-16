"""

This holds all the interface elements and user interaction for the main scene (note creation)



"""

extends Node2D

var Ticks = 0

onready var CurrentCamera = get_node("../CameraFocus/Camera2D")
onready var CameraFocus = get_node("../CameraFocus")

onready var SaveDialog = get_node("CanvasLayer/SaveDialog")
onready var LoadDialog = get_node("CanvasLayer/LoadDialog")

onready var FileIO = get_node("FileIO")

signal dialog_box_popup()
signal dialog_box_closed()
signal mouse_entered_button_area()
signal mouse_exited_button_area()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("dialog_box_popup", CameraFocus, "_on_dialog_box_popup")
	connect("dialog_box_closed", CameraFocus, "_on_dialog_box_closed")
	connect("mouse_entered_button_area", CameraFocus, "_on_mainGUI_mouse_entered_button_area")
	connect("mouse_exited_button_area", CameraFocus, "_on_mainGUI_mouse_exited_button_area")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#
#	Ticks += 1
#	if Ticks % 200 == 0:
#		print("mouse location is " , get_local_mouse_position())
#		print("viewport mouse position is ", get_viewport().get_mouse_position())
#		pass			
		
		

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
	
	

#func _on_FileDialog_popup_hide():
#	emit_signal("dialog_box_closed")
#	if CurrentCamera.has_method("enableZoom"):
#		CurrentCamera.enableZoom()





func _on_HelpButton_pressed():
	var DialogTextArr = [
		"Click and drag to move a note. Use the mouse to direct the magnifying glass. \n\nClick a flower to spawn a new note.\n\nIf the magnifying glass is locked onto a note, you can click on any empty space to free it.",
		"You may also navigate and create notes with the keyboard. shift + arrow keys to move around. ctrl + arrow keys to create new notes."
	]
	spawnDialogBox(DialogTextArr)

func _on_DialogBox_completed():
	emit_signal("dialog_box_closed")

	

func _on_Background_gui_input(event):
	if event is InputEventMouseButton:
		# print("clicked on the canvas")
		pass
		
	elif event is InputEventMouseMotion and Input.is_action_pressed("drag_camera"):
		# send a signal to the rigid body so it can move
		emit_signal("window_dragged", get_global_mouse_position())


func _on_AboutCactusNotesButton_button_down():
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


#func _on_MouseSafeZone_mouse_entered():
#	#tell the CameraFocus to stop moving
#	print("entering mouse safe zone")
#	emit_signal("mouse_entered_button_area")
#
#
#func _on_MouseSafeZone_mouse_exited():
#	print("leaving mouse safe zone")
#	emit_signal("mouse_exited_button_area")





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
	$"CanvasLayer/TimeChallengeButton/Warning Label".show()
	var time = $CanvasLayer/TimeChallengeButton/TimedChallengeTimer.get_wait_time()
	var textArr = [
		"It's said that time pressure can stimulate creativity. \n\nCome up with a project or concept you need to brainstorm. \n\nYou have " + str(time) + " seconds to generate as many ideas as possible."
	]
	
	spawnDialogBox(textArr)
	$CanvasLayer/TimeChallengeButton/TimedChallengeTimer.start()
	$CanvasLayer/TimeChallengeButton/TimedChallengeTimer/TimerCountdown.show()

func spawnRaptor():
	var minDistance = 500
	var maxDistance = 5000
	var distRange = maxDistance - minDistance
	var randDistance = randf()*distRange + minDistance

	var raptor = preload("res://enemies/Raptor.tscn")
	var newRaptor = raptor.instance()
	newRaptor.set_position(to_local(CameraFocus.get_global_position() + Vector2(randDistance, 0).rotated(randf()*2*PI)))
	$Raptors.add_child(newRaptor)

func _on_DefenseChallengeButton_pressed():
	var button = $CanvasLayer/DefenseChallengeButton
	var startTimer = button.get_node("DefenseChallengeStartTimer")
	startTimer.start()
	button.get_node("WarningLabel").show()
	var textArr = [
		"To identify which of your ideas are most important... \n\nsuddenly Dinosaurs! \n\nDefend your thoughts!"
	]
	spawnDialogBox(textArr)

func _on_DefenseChallengeStartTimer_timeout():
	$CanvasLayer/DefenseChallengeButton/WarningLabel.hide()
	var numRaptors = 150
	for i in range(numRaptors):
		spawnRaptor()
	
