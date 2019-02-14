"""

This will handle all the input / output requests, for saving and loading databases.

Refactor Notes:
	Much of the logic here was cut and pasted from the base node 'Mindmapper'.
	It'll be broken and need major rewrites.

"""


extends Node

onready var global = get_node("/root/global")
var GraphNodeContainer
var GraphEdgeContainer

func _ready():
	GraphNodeContainer = global.getRootSceneManager().getCurrentScene().get_node("graphNodes")
	GraphEdgeContainer = global.getRootSceneManager().getCurrentScene().get_node("graphEdges")

func saveFile(path):
	var f = File.new()
	f.open(path, File.WRITE)

	var comprehensiveDict : Dictionary = {}
	comprehensiveDict["Notes"] = getNotesAsDict()
	comprehensiveDict["Springs"] = getSpringsAsDict()

	var jsonString = to_json(comprehensiveDict)
	f.store_string(jsonString)

	print(jsonString)

	f.close()
	


func loadFile(path):
	var mindMapper = global.getRootSceneManager().getCurrentScene()
	# open a JSON file. read each object and convert into a note.
	
	if mindMapper.has_method("cleanup"):
		mindMapper.cleanup()
	
	mindMapper.spawnAnchor()
	
	#print(path)
	var f = File.new()
	f.open(path, File.READ)


	#print("File text: ", f.get_as_text())
	
	var notesDict
	var springsDict
	
	var comprehensiveDict = parse_json(f.get_as_text())
	if typeof(comprehensiveDict) == TYPE_DICTIONARY:
		notesDict = comprehensiveDict["Notes"]
		springsDict = comprehensiveDict["Springs"]
	
		#print("WOO: notesDict: ", notesDict)

	f.close()

	var graphNotesArr = convertNotesDictToArray(notesDict) # because JSON doesn't preserve order
	
	print("graphNotesArr == ", graphNotesArr)
	for note in graphNotesArr:
		if mindMapper.has_method("spawnGraphNode"):
			var newNode = mindMapper.spawnGraphNode(null)
			print(note["pos"])
			newNode.get_node("StickyNote").loadSavedData(note)

	# Get the graphSprings
	for row in springsDict:
		var spring = springsDict[row]
		
		if mindMapper.has_method("spawnGraphSpring"):
			var node_a = mindMapper.getGraphNodeByID(spring["nodeA"])
			var node_b = mindMapper.getGraphNodeByID(spring["nodeB"])
			mindMapper.spawnGraphSpring(node_a, node_b)	


	
func getNotesAsDict():
	#print(self.name, " in getNotesAsDict. Here's the list of notes and their children.")
	
	var notesDict = {}
	var noteID = 0
	for note in GraphNodeContainer.get_children():
		var currentNoteDict = note.get_node("StickyNote").getSaveData()
		notesDict[noteID] = currentNoteDict
		noteID += 1
	return notesDict

func getSpringsAsDict():
	#print(self.name, " here's a list of springs and their nodes" )
	var springsDict = {}
	var springID = 0
	for spring in GraphEdgeContainer.get_children():
		var currentSpringDict = spring.getSaveData()
		springsDict[springID] = currentSpringDict
		springID += 1
	return springsDict

func findRecordByIDField(dict : Dictionary, idNum : float):
	#print("WTF: Here's the dictionary ", dict)
	var result
	for item in dict:
		#print("item: ", item)
		#print(dict.get(item))
		if dict.get(item)["ID"] == idNum:
			result = dict.get(item)
	return result # returning a dictionary

func convertNotesDictToArray(notesDict):
	# JSON doesn't preserve the order of records..
	# take a dictionary where each record has an ID field,
	# and convert it to an array in the correct order

	var graphNotesArr : Array = []
	for i in notesDict.size():
		graphNotesArr.push_back(findRecordByIDField(notesDict, i))
	return graphNotesArr # an array of dictionaries in the correct order



func _on_LoadDialog_file_selected(path):
	loadFile(path)
		

func _on_SaveDialog_file_selected(path):
	saveFile(path)
	#print(nodeDict)
	
#func _on_new_note_requested(nodeRequesting):
#	var mindMapper = global.getRootSceneManager().getCurrentScene()
#	if mindMapper.has_method("spawnNote"):
#		spawnNote("", "", 1, nodeRequesting, nodeRequesting.get_global_position() + Vector2(0, -100), null)
	




