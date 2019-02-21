extends Node2D

# Declare member variables here. Examples:
export var InstructionText : String
onready var global = get_node("/root/global")
var MainGUI
var ChallengeType : String
var CompletionTextArr : Array
signal started_challenge(challengeType)
signal completed_challenge(challengeType)

# Called when the node enters the scene tree for the first time.
func _ready():
	MainGUI = global.getRootSceneManager().getCurrentScene().getMainGUI()
	
	$Instructions/StartButton.connect("pressed", self, "_on_StartButton_pressed")
	$Instructions/ReturnButton.connect("pressed", self, "_on_ReturnButton_pressed")
	connect("started_challenge", MainGUI, "_on_Challenge_started")
	connect("completed_challenge", MainGUI, "_on_Challenge_completed")
	
	self.hide()
	$Instructions.hide()
	$CountdownPanel.hide()
	$CountdownPanel/ChallengeTimer.connect("timeout", self, "_on_timer_timeout")

func start(challengeType : String, instructionText : String, duration : float, completionTextArr : Array):

	self.show()
	$Instructions.show()
	if instructionText != "":
		InstructionText == instructionText
		$Instructions/Description.set_bbcode(instructionText)
	ChallengeType = challengeType
	$CountdownPanel/ChallengeTimer.set_wait_time(duration)
	
	CompletionTextArr = completionTextArr
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	# hide the dialog and send a signal to maingui to start the challenge
	emit_signal("started_challenge", ChallengeType)
	$Instructions.hide()
	$CountdownPanel.show()
	$CountdownPanel/CountdownLabel.show()
	$CountdownPanel/ChallengeTimer.start()
	
func _on_ReturnButton_pressed():
	# hide the dialog
	self.hide()

func _on_timer_timeout():
	emit_signal("completed_challenge", ChallengeType)
	MainGUI.spawnDialogBox(CompletionTextArr)
	$CountdownPanel.hide()
	
func _on_challenge_ended():
	$CountdownPanel/ChallengeTimer.stop()
	self.hide()
	$CountdownPanel.hide()
	