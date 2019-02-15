extends AnimatedSprite


# Declare member variables here. Examples:

enum STATES { passive, tracking, dragging, swiping, frozen }
var StateStrings = ["passive", "tracking", "dragging", "swiping", "frozen"]
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

signal node_activated()
signal node_deactivated()

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

func rotateSearchArea(directionVector):
	$SearchArea.look_at(get_global_position() + directionVector)
	
func moveToNearestNode(directionVector):
	rotateSearchArea(directionVector)
	$SearchArea/Timer.start()
	# the physics engine needs a moment to update the collision area.
	# when the Timer ends, find nearest node will be called

func findNearestNode():
	# scan the field in the direction of Vector and get the closest cactus
	var dist = 2048
	var candidates = $SearchArea.get_overlapping_bodies()
	var myPos = get_global_position()
	#print("ActiveNode == ", ActiveNode.name)
	var bestCandidate
	if candidates.size() > 0:
		var nearestDistSq = pow(dist * 2, 2)
		for candidate in candidates:
			var candidatePos = candidate.get_global_position()
			var thisDistSq = myPos.distance_squared_to(candidatePos)
			if thisDistSq < nearestDistSq:
				nearestDistSq = thisDistSq
				bestCandidate = candidate
		if bestCandidate != null and bestCandidate != ActiveNode:
			#print("found a new candidate", bestCandidate.name)
			setActiveNode(bestCandidate)
			setState(STATES.tracking)
	

func deactivateNode(node):
	connect("node_deactivated", node.get_node("StickyNote"), "_on_CameraFocus_node_deactivated")
	emit_signal("node_deactivated")
	disconnect("node_deactivated", node.get_node("StickyNote"), "_on_CameraFocus_node_deactivated")
	
func setActiveNode(node):
	if ActiveNode != null:
		deactivateNode(ActiveNode)
	
	
	if node.has_node("StickyNote"):
		ActiveNode = node
		connect("node_activated", node.get_node("StickyNote"), "_on_CameraFocus_node_activated")
		emit_signal("node_activated")
		disconnect("node_activated", node.get_node("StickyNote"), "_on_CameraFocus_node_activated")
	
	

	
func _input(event):
	
	var directionVector : Vector2
	if event is InputEventKey and Input.is_action_just_pressed("node_up"):
		directionVector = Vector2(0, -1)
		moveToNearestNode(directionVector)
	elif event is InputEventKey and Input.is_action_just_pressed("node_down"):
		directionVector = Vector2(0, 1)
		moveToNearestNode(directionVector)
	elif event is InputEventKey and Input.is_action_just_pressed("node_left"):
		directionVector = Vector2(-1, 0)
		moveToNearestNode(directionVector)
	elif event is InputEventKey and Input.is_action_just_pressed("node_right"):
		directionVector = Vector2(1, 0)
		moveToNearestNode(directionVector)
		
	
	

func _process(delta):
#	if get_viewport().get_mouse_position().y > 500:
#		return # ignore mouse requests if you're near the button bar.
		# ^^^ THIS IS A HACK. Needs a better, long-term solution
		
		
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
			#getNodeNavigationRequests()
			set_global_position(ActiveNode.get_global_position())

		STATES.frozen: # there's a dialog box open
			pass 
			
	update()
	
func _draw():
	var zoom = MyCamera.zoom.x
	draw_string(global.BaseFont, $FocalPoint.position + Vector2(-15, -65.0), "Zoom: " + str(zoom), Color(0.8, 1.0, 0.8, 0.5))

	#draw_string(global.BaseFont, $FocalPoint.position + Vector2(-15, -45.0), "State: " + StateStrings[CurrentState], Color.antiquewhite )


func _on_picked_up_cactus(activeNode): # signal from StickyNote
	setActiveNode(activeNode)
	setState(STATES.dragging)
	
func _on_released_cactus(): # signal from StickyNote
	setState(STATES.tracking)

func _on_camera_drag_requested():
	var offsetVector = Vector2(-200, 0)
	set_global_position(get_global_mouse_position() + offsetVector)
	setState(STATES.swiping)
	
func _on_node_spawned(node):
	setActiveNode(node)
	setState(STATES.tracking)

func _on_dialog_box_popup():
	setState(STATES.frozen)
	PreviousStates.push_back(CurrentState)

func _on_dialog_box_closed():
	if PreviousStates.size() > 0:
		setState(PreviousStates.pop_back())
	else:
		setState(STATES.idle)

func _on_Timer_timeout():
	findNearestNode()

func _on_mainGUI_mouse_entered_button_area():
	setState(STATES.frozen)
	PreviousStates.push_back(CurrentState)
	
func _on_mainGUI_mouse_exited_button_area():
	if PreviousStates.size() > 0:
		setState(PreviousStates.pop_back())
	else:
		setState(STATES.idle)
	




#func _on_BurnArea_body_entered(body):
#	if body.is_in_group("enemies"):
#		if body.has_method("_on_burn"):
#			var damage = 10
#			body._on_burn(damage)
			


func _on_BurnArea_area_entered(area):
	if area.is_in_group("enemies"):
		if area.has_method("_on_burn"):
			var damage = 10
			area._on_burn(damage)
			
func _on_cactus_died(cactusNode):
	if ActiveNode == cactusNode:
		if CurrentState != STATES.frozen:
			setState(STATES.passive)
		ActiveNode = null
	