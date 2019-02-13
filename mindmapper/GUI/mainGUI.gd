"""

This holds all the interface elements and user interaction for the main scene (note creation)



"""

extends Node2D

onready var CurrentCamera = get_node("../CameraFocus/Camera2D")
onready var SaveDialog = get_node("CanvasLayer/SaveDialog")
onready var LoadDialog = get_node("CanvasLayer/LoadDialog")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


		
		

func spawnDialogBox(textArray):
	var dialogBoxScene = preload("res://DialogBox.tscn")
	var newDialogBox = dialogBoxScene.instance()
	$DialogBoxes.add_child(newDialogBox)
	
	newDialogBox.start(textArray, self)

###################
# Camera settings: disable it when dialogs are open.
###################
func _on_SaveButton_pressed():
	SaveDialog.popup_centered()
	# disable the camera so we can use the scroll wheel
	if CurrentCamera.has_method("disableZoom"):
		CurrentCamera.disableZoom()


func _on_LoadButton_pressed():
	LoadDialog.popup_centered()
	# disable the camera so we can use the scroll wheel
	if CurrentCamera.has_method("disableZoom"):
		CurrentCamera.disableZoom()

func _on_FileDialog_popup_hide():
	if CurrentCamera.has_method("enableZoom"):
		CurrentCamera.enableZoom()





func _on_HelpButton_pressed():
	print("Help Button pressed")
	var DialogTextArr = [
		"Click and drag to move a note. Click the flower or press ctrl-n to spawn a new note.\n\n New notes will grab focus, so you can start typing into them right away."
	]
	spawnDialogBox(DialogTextArr)

func _on_DialogBox_completed():
	pass
	

func _on_Background_gui_input(event):
	if event is InputEventMouseButton:
		print("clicked on the canvas")
		
	elif event is InputEventMouseMotion and Input.is_action_pressed("drag_camera"):
		# send a signal to the rigid body so it can move
		emit_signal("window_dragged", get_global_mouse_position())
