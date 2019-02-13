extends Sprite


# Declare member variables here. Examples:

var Speed : float = 20
enum STATES { idle, tracking }
var CurrentState = STATES.idle

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func moveTowardsMousePosition():
	var vectorToMouse = get_global_mouse_position() - get_global_position()
	set_global_position(get_global_position() + Speed * vectorToMouse.normalized() )
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
#	moveTowardsMousePosition()
	
	if Input.is_action_just_pressed("drag_camera"):
		CurrentState = STATES.tracking
	
	if Input.is_action_just_released("drag_camera"):
		CurrentState = STATES.idle

	if CurrentState == STATES.tracking and Input.is_action_pressed("drag_camera"):
		set_global_position(get_global_mouse_position())
