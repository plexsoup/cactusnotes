"""
Responsible for zooming the camera in and out.
"""


extends Camera2D

# Declare member variables here. Examples:
# var a = 2

#onready var ViewTarget = get_node("../Crane/Muzzle")
export (bool) var ZoomAllowed = true
export (float) var ZoomSpeed = 3.0
export (float) var ZoomIncrement = 0.25
export var RepositionSpeed : float = 0.25
var InitialZoom = Vector2(1.0, 1.0)
var MinZoom = Vector2(0.2, 0.2)
var MaxZoom = Vector2(15.0, 15.0)

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
	DesiredZoom *= (1 - ZoomIncrement)
	if DesiredZoom.x < MinZoom.x:
		DesiredZoom = MinZoom
		
	#self.zoom = DesiredZoom
	
	var vectorToCursor = FocalPoint.get_global_position() - get_global_position()
	set_global_position(get_global_position() + vectorToCursor/3 )
	# Can I just increase the drag margins as zoom increases?
	


func zoomOut():
	DesiredZoom *= (1 + ZoomIncrement)
	if DesiredZoom.x > MaxZoom.x:
		DesiredZoom = MaxZoom

func zoomTowardDesiredZoom(delta):
	if ZoomAllowed == true:
		self.zoom = lerp(zoom, DesiredZoom, ZoomSpeed * delta)

func _physics_process(delta):
	if CurrentState == STATES.dragging:
		var currentMousePosition = get_global_mouse_position()
		var mousePositionDelta = LastMousePosition - currentMousePosition
		set_global_position(get_global_position() + mousePositionDelta )
		LastMousePosition = currentMousePosition
		#CameraFocus.set_global_position(currentMousePosition)
	
	zoomTowardDesiredZoom(delta)
	
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
	
	
	
	