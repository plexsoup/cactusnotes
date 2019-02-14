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

var ComprehensiveDict : Dictionary
var NotesDict : Dictionary
var SpringsDict : Dictionary

var MindMapper

func _ready():
	MindMapper = global.getRootSceneManager().getCurrentScene()
	GraphNodeContainer = MindMapper.get_node("graphNodes")
	GraphEdgeContainer = MindMapper.get_node("graphEdges")
	

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
	

func buildDictionariesFromJSON(jsonText):
	ComprehensiveDict = parse_json(jsonText)
	NotesDict = ComprehensiveDict["Notes"]
	SpringsDict = ComprehensiveDict["Springs"]
	

func loadFile(path):
	# open a JSON file. read each object and convert into a note.
	
	if MindMapper.has_method("cleanup"):
		print("cleaning up old canvas")
		MindMapper.cleanup()
	var f = File.new()
	f.open(path, File.READ)
	buildDictionariesFromJSON(f.get_as_text())

	f.close()

	# resequence the loaded JSON file
	
	#var graphNotesArr = convertNotesDictToArray(NotesDict) # because JSON doesn't preserve order
	
	var graphNotesArr = Array(NotesDict.values())
	

	# spawn the graph
	spawnNotesFromArray(graphNotesArr)
	spawnSpringsFromDict(SpringsDict)

func spawnNotesFromArray(graphNotesArr : Array):
	print("graphNotesArr == ", graphNotesArr)


		
	#spawn all the StickyNotes
	for note in graphNotesArr:
		if note == null:
			breakpoint
			
		if MindMapper.has_method("spawnGraphNode"):
			var newNode = MindMapper.spawnGraphNode(null)
			if newNode.has_node("StickyNote"):
				#breakpoint
				newNode.get_node("StickyNote").loadSavedData(note)
			else:
				print(self.name, " in spawnNotesFromArray: ", newNode , " doesn't have a StickyNote" )


func spawnSpringsFromDict(springsDict : Dictionary):
	# Get the graphSprings
	for row in springsDict:
		var spring = springsDict[row]
		print(self.name, " in loadFile: spring == ", spring )
		
		if MindMapper.has_method("spawnGraphSpring"):
			print("--== look here ==--")
			var node_a = MindMapper.getGraphNodeByID(spring["nodeA"])
			print("== spring[nodeA] == ", spring["nodeA"] )
			print("== node_a == ", node_a) 
			var node_b = MindMapper.getGraphNodeByID(spring["nodeB"])
			print("== spring[nodeB] == ", spring["nodeB"])
			print("== node_b == ", node_b)
			MindMapper.spawnGraphSpring(node_a, node_b)
			print("--===============--")

	
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
	var springsDict = {}
	var springID = 0
	for spring in GraphEdgeContainer.get_children():
		var currentSpringDict = spring.getSaveData()
		springsDict[springID] = currentSpringDict
		springID += 1
	return springsDict

func findRecordByIDField(dict : Dictionary, idNum : int):
	var result
	for i in dict:
		var item = dict[i] 
		if item["ID"] == str(idNum):
			result = item
	#breakpoint
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
	
	




