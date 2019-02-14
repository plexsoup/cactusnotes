extends AnimatedSprite


# Declare member variables here. Examples:

enum STATES { passive, tracking, dragging, swiping, frozen }
	# swiping refers to the canvas. user is trying to drag the map, which moves the camera in the opposite direction of the cursor
	# dragging refers to a cactus node. User is trying to move a node.
	# tracking refers to a cactus node. User just spawned a node and the cursor should highlight it.
	# passive is when the avatar is trying to keep up with the mouse onscreen.
	# frozen is for when a dialog box has focus (save/load, etc.). It should prevent the camera from moving
var CurrentState = STATES.passive
var PreviousStates : Array = []


var Velocity : Vector2
var InitialSpeed: float = 400
var Speed : float
onready var MyCamera = get_node("Camera2D")
var ActiveNode

var HaltProximity : float = 75 # don't move the avatar if you're this close to the mouse cursor
var StableProximity : float = 125 # don't rotate the avatar if you're inside this radius
var HaltProximitySq : float
var StableProximitySq : float


# Called when the node enters the scene tree for the first time.
func _ready():
	HaltProximitySq  = pow(HaltProximity, 2)
	StableProximitySq = pow(StableProximity, 2)
	
func setState(state):
	CurrentState = state

func getState():
	return CurrentState
	
func pretendToDragCactus():
	set_animation("hand")

func pretendToInspect():
	set_animation("glass")

func pretendToSwipe():
	set_animation("swipe")

func moveTowardsMousePosition(delta):
	var speed = InitialSpeed * MyCamera.zoom.x
	var destination = get_global_mouse_position()
	moveToDestination(delta, destination, speed)

func moveToDestination(delta, destination, speed):
	var myPos = get_global_position()
	var vectorToDestination = destination - myPos
	var directionVector = vectorToDestination.normalized()

	var distSqToDestination = myPos.distance_squared_to(destination)
	if distSqToDestination > HaltProximitySq * MyCamera.zoom.x:
		set_global_position(myPos + directionVector * speed * delta * global.GameSpeed)
	
	if distSqToDestination > StableProximitySq:
		# having a zone of rotational stability allows the user to nudge the avatar backwards without rotating it
		look_at(destination)

func moveToCactus(delta):
	var speed = InitialSpeed * 2 * MyCamera.zoom.x
	var destination = ActiveNode.get_global_position()
	moveToDestination(delta, destination, speed)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	match CurrentState:
		STATES.passive:
			# move the avatar (magnifying glass) towards the mouse cursor
			pretendToInspect()
			moveTowardsMousePosition(delta)
	
		STATES.swiping:
			# unique case: we want the camera to move away from the cursor
			if Input.is_action_just_released("drag_camera"):
				setState(STATES.passive)
			else:
				pretendToSwipe()
	
		STATES.dragging:
			pretendToDragCactus()
			moveToCactus(delta)
			
		STATES.tracking:
			pretendToInspect()
			var offsetVector = Vector2(0, 0).rotated(get_rotation())
			set_global_position(ActiveNode.get_global_position() - offsetVector)

		STATES.frozen:
			pass
			
	update()
	
func _draw():
	var zoom = MyCamera.zoom.x
	draw_string(global.BaseFont, $FocalPoint.position + Vector2(-15, -65.0), "Zoom: " + str(zoom), Color(0.8, 1.0, 0.8, 0.5))

func _on_picked_up_cactus(activeNode): # signal from StickyNote
	ActiveNode = activeNode
	setState(STATES.dragging)
	
func _on_released_cactus(): # signal from StickyNote
	setState(STATES.tracking)

func _on_camera_drag_requested():
	var offsetVector = Vector2(-200, 0)
	set_global_position(get_global_mouse_position() + offsetVector)
	setState(STATES.swiping)
	
func _on_node_spawned(node):
	ActiveNode = node
	setState(STATES.tracking)

func _on_dialog_box_popup():
	setState(STATES.frozen)
	PreviousStates.push_back(CurrentState)

func _on_dialog_box_closed():
	if PreviousStates.size() > 0:
		setState(PreviousStates.pop_back())
	else:
		setState(STATES.idle)