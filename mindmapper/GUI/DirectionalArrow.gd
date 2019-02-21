"""
Rotate the sprite to always point the nagigation arrow toward the Anchor Node.
"""

extends Sprite

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
var CurrentScene
var AnchorNode
var AnchorNodePos
var Ticks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	CurrentScene = global.getRootSceneManager().getCurrentScene()
	AnchorNodePos = Vector2(0,0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1

	if AnchorNode != null:
		look_at(AnchorNodePos)
	else:
		if Ticks % 200 == 0: # don't pester the main scene.
			AnchorNode = CurrentScene.getAnchorNode()
			AnchorNodePos = AnchorNode.get_global_position()
		