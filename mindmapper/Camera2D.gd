extends Camera2D

# Declare member variables here. Examples:
# var a = 2

#onready var ViewTarget = get_node("../Crane/Muzzle")
export (bool) var ZoomAllowed = true
export (float) var ZoomSpeed = 0.1
export var RepositionSpeed : float = 0.25
var InitialZoom = Vector2(1.0, 1.0)
var DesiredZoom = InitialZoom


func _ready():
	zoom = InitialZoom

func zoomToCursor():
	#self.zoom -= Vector2(zoomSpeed, zoomSpeed)
	DesiredZoom -= Vector2(ZoomSpeed, ZoomSpeed)
	if DesiredZoom.x < 0.1:
		DesiredZoom = Vector2(0.1, 0.1)
		
	self.zoom = DesiredZoom
	
	
	var vectorToMouse = get_global_mouse_position() - get_global_position()
	set_global_position(get_global_position() + vectorToMouse * RepositionSpeed)


func zoomOut():
	#self.zoom += Vector2(zoomSpeed, zoomSpeed)
	DesiredZoom += Vector2(ZoomSpeed, ZoomSpeed)
	self.zoom = DesiredZoom
	if DesiredZoom.x > 8.0:
		DesiredZoom = Vector2(8, 8)
	var vectorToMouse = get_global_mouse_position() - get_global_position()
	set_global_position(get_global_position())

	
func _input(event):
	#print(self.name, " zoom == ", get_zoom() )
	if event.is_action_pressed("zoom_in") == true and ZoomAllowed == true:
		zoomToCursor()
	elif event.is_action_pressed("zoom_out") == true and ZoomAllowed == true:
		zoomOut()

func disableZoom():
	ZoomAllowed = false
	self.zoom = InitialZoom
	
func enableZoom():
	ZoomAllowed = true
	self.zoom = DesiredZoom

