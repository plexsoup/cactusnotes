extends Node

var RootSceneManager
var GameSpeed : float = 1.0
var BaseFont

func setRootSceneManager(node):
	RootSceneManager = node
	
func getRootSceneManager():
	return RootSceneManager
	
func getCameraFocus():
	return RootSceneManager.getCurrentScene().get_node("CameraFocus")
	