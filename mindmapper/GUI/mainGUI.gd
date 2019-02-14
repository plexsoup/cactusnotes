"""

This holds all the interface elements and user interaction for the main scene (note creation)



"""

extends Node2D

onready var CurrentCamera = get_node("../CameraFocus/Camera2D")
onready var CameraFocus = get_node("../CameraFocus")

onready var SaveDialog = get_node("CanvasLayer/SaveDialog")
onready var LoadDialog = get_node("CanvasLayer/LoadDialog")

onready var FileIO = get_node("FileIO")

signal dialog_box_popup()
signal dialog_box_closed()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("dialog_box_popup", CameraFocus, "_on_dialog_box_popup")
	connect("dialog_box_closed", CameraFocus, "_on_dialog_box_closed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


		
		

func spawnDialogBox(textArray):
	emit_signal("dialog_box_popup")
	var dialogBoxScene = preload("res://DialogBox.tscn")
	var newDialogBox = dialogBoxScene.instance()
	$DialogBoxes.add_child(newDialogBox)
	
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
		"Click and drag to move a note. Click the flower or press ctrl-n to spawn a new note.\n\n New notes will grab focus, so you can start typing into them right away."
	]
	spawnDialogBox(DialogTextArr)

func _on_DialogBox_completed():
	emit_signal("dialog_box_closed")

	

func _on_Background_gui_input(event):
	if event is InputEventMouseButton:
		print("clicked on the canvas")
		
	elif event is InputEventMouseMotion and Input.is_action_pressed("drag_camera"):
		# send a signal to the rigid body so it can move
		emit_signal("window_dragged", get_global_mouse_position())


func _on_AboutCactusNotesButton_button_down():
	var DialogTextArr = [
		"Cactus Notes is a mindmapping / brainstorming application developed for the Sixth Godot Wild Game Jam. It was intended as a replacement for paper and whiteboards, for use in the Game Design planning process...",
		"... at least, that was the intention. It turned out to be more of a conspiracy board application.",
		"Source code is available at [url]https://github.com/plexsoup/[/url]",
		"Thanks for trying it!"
	]
	spawnDialogBox(DialogTextArr)




	


func _on_SaveDialog_popup_hide():
	print("save dialog popup hidden")
	emit_signal("dialog_box_closed")
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()



func _on_LoadDialog_popup_hide():
	print("load dialog popup hidden")
	emit_signal("dialog_box_closed")
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()
