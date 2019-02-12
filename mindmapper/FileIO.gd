"""

This will handle all the input / output requests, for saving and loading databases.

Refactor Notes:
	Much of the logic here was cut and pasted from the base node 'Mindmapper'.
	It'll be broken and need major rewrites.

"""


extends Node


func _on_SaveDialog_file_selected(path):
	print(path)

	var f = File.new()
	
	f.open(path, File.WRITE)
	
	var noteID = 0
	var comprehensiveDict : Dictionary = {}
	comprehensiveDict["Notes"] = {}
	
	for note in $SpawnedNotes.get_children():
		# read the title, the note, the pin status, and the coordinates
		# then write to a file
		var currentNoteDict : Dictionary = {}	

		var noteContainer = note.get_node("WindowDialog")
		var noteTitle = note.get_node("WindowDialog/NoteName").get_text()
		var noteText = note.get_node("WindowDialog/NoteContents/NoteText").get_text()

		currentNoteDict["ID"] = noteID
		currentNoteDict["Title"] = noteTitle
		currentNoteDict["Text"] = noteText
		currentNoteDict["PinMode"] = noteContainer.CurrentPinState
		currentNoteDict["Position"] = note.get_global_position()

		#notesArr.push_back(currentNoteDict)

		comprehensiveDict["Notes"][noteID] = currentNoteDict
		
		noteID += 1
	
	var springID = 0
	var currentSpringDict = {}
	for edge in $Springs.get_children():
		pass
		currentSpringDict[springID] = { 'nodeA': edge.get_node_a(), 'nodeB': edge.get_node_b() }
		# ^^^ this is dumb. We need a nodes and edges database for the graph.
			# the list of edges would link nodeIDs
		

		springID += 1
		
	
	var jsonString = to_json(comprehensiveDict)
	f.store_string(jsonString)

	print(jsonString)

	
	f.close()
	
		


func _on_LoadDialog_file_selected(path):
	# open a JSON file. read each object and convert into a note.
	
	if global.getRootSceneManager().getCurrentScene(has_method("cleanup")):
		global.getRootSceneManager().getCurrentScene().cleanup()
	
	print(path)
	var f = File.new()
	f.open(path, File.READ)

	# BUG: Fix loading json. 
	# Seems like I'm only getting one record.
	# Do i have to loop over every line?
	print("File text: ", f.get_as_text())
	var notesDict : Dictionary = parse_json(f.get_as_text())
	print("notesDict: ", notesDict)

	f.close()
	
	for row in notesDict:
		var note = notesDict[row]
		
		var mindMapper = global.getCurrentRootNode().getCurrentScene()
		if mindMapper.has_method("spawnNote"):
			mindMapper.spawnNote(note["Title"], note["Text"], note["PinMode"], note["AttachedTo"], note["Position"], note["ID"])
	
	#print(nodeDict)
	
#func _on_new_note_requested(nodeRequesting):
#	var mindMapper = global.getCurrentRootNode().getCurrentScene()
#	if mindMapper.has_method("spawnNote"):
#		spawnNote("", "", 1, nodeRequesting, nodeRequesting.get_global_position() + Vector2(0, -100), null)
	




