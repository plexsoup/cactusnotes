extends Node2D

# Declare member variables here. Examples:
onready var global = get_node("/root/global")

signal fadeOut_finished()
signal fadeIn_finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("fadeOut_finished", global.getRootSceneManager(), "_on_FadeTransition_fadeOut_finished")
	$CanvasLayer/ColorRect.set_mouse_filter(2)

func fadeIn():
	print(self.name, " fading in")
	$AnimationPlayer.play("fadeIn")
	
func fadeOut():
	$AnimationPlayer.play("fadeOut")





func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeOut":
		print(self.name, " emitting signal: fadeOut_finished")
		if is_connected("fadeOut_finished", global.getRootSceneManager(), "_on_FadeTransition_fadeOut_finished") == false:
			connect("fadeOut_finished", global.getRootSceneManager(), "_on_FadeTransition_fadeOut_finished")
		emit_signal("fadeOut_finished") # for the Root Scene Manager
	if anim_name == "fadeIn":
		if is_connected("fadeIn_finished", global.getRootSceneManager(), "_on_FadeTransition_fadeIn_finished") == false:
			connect("fadeIn_finished", global.getRootSceneManager(), "_on_FadeTransition_fadeIn_finished")
		emit_signal("fadeIn_finished")
		