extends Sprite

# Declare member variables here. Examples:
onready var StickyNote = get_node("..")
onready var global = get_node("/root/global")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func lookAtSlowly( delta, targetPos):

		
	rotation = global.lerp_angle(rotation, Vector2(1,0).angle_to_point(get_global_position()-targetPos), 8.0 * delta)

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#set_rotation(lerp(get_rotation(), get_angle_to(get_global_mouse_position()), 0.8))
	lookAtSlowly(delta, get_global_mouse_position())