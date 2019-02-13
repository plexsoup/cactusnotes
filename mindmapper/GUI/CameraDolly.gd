extends Position2D

# when the mouse is up, do nothing
# when the mouse is just_pressed, set initialPosition Vector2
# when the mouse is down, move to the mouse position.

# tell the camera to move it's position to the same delta.


# Declare member variables here. Examples:
enum STATES { idle, tracking }
var CurrentState = STATES.idle

func setState(state):
	CurrentState = state

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_global_position(get_global_mouse_position())

	if Input.is_action_just_pressed("drag_camera"):
		setState(STATES.tracking)

	elif Input.is_action_just_released("drag_camera"):
		setState(STATES.idle)
		
		
		
		
		
		
		
		
		