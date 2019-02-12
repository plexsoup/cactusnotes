extends Node2D

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
signal start_button_pressed()

export var IntroTextArr = [
	"[b]This[/b] requires an explanation... \n\n[right][i]Press enter or space to continue, escape to skip.[/i][/right]",
	"For creative professionals, when facing a new project, the mind can seem like a desert, bereft of ideas. Cactus Notes will help ideas flourish, like little cacti.",

	"Once we get started, you'll see a cactus. Click on the flower to create a new note. Click and drag a note to move it. Double click to edit a note's contents.",
	
	"If you're looking for more inspiration, you can select an additional challenge mode. Consider a timed challenge or a reconstruction challenge."

]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	spawnDialogBox(IntroTextArr)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		startLevel()
#	elif Input.is_action_just_pressed("ui_cancel"):
#		quitGame()


func spawnDialogBox(textArray):
	var dialogBoxScene = preload("res://DialogBox.tscn")
	var newDialogBox = dialogBoxScene.instance()
	$DialogBoxes.add_child(newDialogBox)
	
	newDialogBox.start(textArray, self)
	
	
func quitGame():
	get_tree().quit()
	

func _on_StartButton_pressed():
	global.getRootSceneManager().launchMindMapper()
	
func _on_StartTimer_timeout():
	emit_signal("start_button_pressed")


func _on_ExitButton_pressed():
	quitGame()

func _on_DryerSprite_gui_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		global.getRootSceneManager().launchMindMapper()
		
		
func _on_DialogBox_completed():
	global.getRootSceneManager().launchMindMapper()
	