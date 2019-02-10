extends GraphEdit

# Declare member variables here. Examples:
onready var GraphNode = $GraphNode

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	var enable_left = true
	var type_left = 0
	var color_left = Color(1, 0, 0)
	var enable_right = false
	var type_right = 0
	var color_right = Color(0, 1, 0)
	var custom_left : Texture = null
	var custom_right : Texture = null

	GraphNode.set_slot( index, 
			enable_left, type_left, color_left, 
			enable_right, type_right, color_right, 
			custom_left, custom_right )

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
