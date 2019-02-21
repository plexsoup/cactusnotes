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

func wait(time):
	var t = Timer.new()
	t.set_wait_time(time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	remove_child(t)
	t.queue_free()

static func lerp_angle(a : float, b: float, t: float):
    if abs(a-b) >= PI:
        if a > b:
            a = normalize_angle(a) - 2.0 * PI
        else:
            b = normalize_angle(b) - 2.0 * PI
    return lerp(a, b, t)


static func normalize_angle(x):
    return fposmod(x + PI, 2.0*PI) - PI
	