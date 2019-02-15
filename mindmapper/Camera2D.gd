extends Camera2D

# Declare member variables here. Examples:
# var a = 2

#onready var ViewTarget = get_node("../Crane/Muzzle")
export (bool) var ZoomAllowed = true
export (float) var ZoomSpeed = 0.1
export var RepositionSpeed : float = 0.25
var InitialZoom = Vector2(1.0, 1.0)
var DesiredZoom = InitialZoom
onready var CameraFocus = $".."
onready var FocalPoint = $"../FocalPoint"
var CurrentMouseOffset : Vector2


enum STATES { idle, dragging }
var CurrentState = STATES.idle

var CanvasTransform
var LastMousePosition


func _ready():
	zoom = InitialZoom
	LastMousePosition = get_global_mouse_position()


func setState(state):
	CurrentState = state


func zoomToCursor():
	#self.zoom -= Vector2(zoomSpeed, zoomSpeed)
	DesiredZoom -= Vector2(ZoomSpeed, ZoomSpeed)
	if DesiredZoom.x < 0.1:
		DesiredZoom = Vector2(0.1, 0.1)
		
	self.zoom = DesiredZoom
	
	var vectorToCursor = FocalPoint.get_global_position() - get_global_position()
	set_global_position(get_global_position() + vectorToCursor/3 )
	# Can I just increase the drag margins as zoom increases?
	


func zoomOut():
	#self.zoom += Vector2(zoomSpeed, zoomSpeed)
	DesiredZoom += Vector2(ZoomSpeed, ZoomSpeed)
	self.zoom = DesiredZoom
	if DesiredZoom.x > 8.0:
		DesiredZoom = Vector2(8, 8)

func _physics_process(delta):
	if CurrentState == STATES.dragging:
		var currentMousePosition = get_global_mouse_position()
		var mousePositionDelta = LastMousePosition - currentMousePosition
		set_global_position(get_global_position() + mousePositionDelta )
		LastMousePosition = currentMousePosition
		#CameraFocus.set_global_position(currentMousePosition)
	
func _input(event):
	if CameraFocus.getState() == CameraFocus.STATES.frozen:
		#don't zoom the camera during dialog box popups
		return
		
	#print(self.name, " zoom == ", get_zoom() )
	if event.is_action_pressed("zoom_in") == true and ZoomAllowed == true:
		zoomToCursor()
	elif event.is_action_pressed("zoom_out") == true and ZoomAllowed == true:
		zoomOut()

	if Input.is_action_just_released("drag_camera"):
		setState(STATES.idle)




func disableZoom():
	ZoomAllowed = false
	self.zoom = InitialZoom
	
func enableZoom():
	ZoomAllowed = true
	self.zoom = DesiredZoom

func _on_camera_drag_requested():
#	LastMousePosition = get_global_mouse_position()
#	setState(STATES.dragging)
	pass

func zoomToFocus():
	set_global_position(CameraFocus.get_global_position())
	
#func _on_node_spawned(node): # from Mindmapper.gd
#	CameraFocus.set_global_position(node.get_global_position())
#	zoomToFocus()
	
	
	
	