extends RigidBody2D

# Declare member variables here. Examples:
onready var NoteWindow = get_node("WindowDialog")
onready var global = get_node("/root/global")
var Time = 0

signal new_note_requested(nodeRequesting)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(newPosition, pinStatus, title, text, id):
	call_deferred("set_global_position", newPosition)
	NoteWindow.start(self, pinStatus, title, text, id)
	connect("new_note_requested", global.getRootSceneManager(), "_on_new_note_requested")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var windowDialog = $WindowDialog
	var width = windowDialog.get_rect().size.x
	var height = windowDialog.get_rect().size.y
	$WindowDialog.set_global_position(self.get_global_position() - Vector2(width/2, height/2))
	Time += delta
		
func setStatic():
	set_mode(MODE_STATIC)
	$Sprite.set_modulate(Color(1, 0.5, 0))
	
func setRigid():
	set_mode(MODE_RIGID)
	$Sprite.set_modulate(Color(1, 1, 1))

func changeMode(newMode):
	if newMode == MODE_RIGID:
		set_mode(MODE_RIGID)
		apply_central_impulse(Vector2(0.0, 0.0))
	elif newMode == MODE_STATIC:
		set_mode(MODE_STATIC)

func _on_WindowDialog_window_dragged(mouseCoordinates):
	#if get_mode() == MODE_STATIC:
	call_deferred("set_global_position", mouseCoordinates)

func _on_WindowDialog_pinned():
	changeMode(MODE_STATIC)

func _on_WindowDialog_unpinned():
	changeMode(MODE_RIGID)



func _on_NewNodeBTN_pressed():
	emit_signal("new_note_requested", self)
	