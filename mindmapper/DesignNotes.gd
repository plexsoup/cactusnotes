"""
Cactus Notes is a mindmapper / idea processor.

By default, notes are:
	Very simple. They show only a title and a text box.
	Able to move around on the canvas
	
Users should be able to:
	create notes which are arranged in a force-directed spring graph.
	pin individual notes so they don't move around
	rearrange notes based on user-defined edges, tags, dates, assignee
	hide/reveal detailed form fields: tags, dates, assignee, etc.
	create subnotes
	create relationships between notes
	
UI / UX:
	click a cactus node to create a new subnote
	click and drag to move a note (it will be placed in pinned (STATIC) mode automatically)
	double click a note to edit it's contents.
		double clicking will reveal some buttons:
			ID Card: shows more fields: tags, assignee, dates, priority, label
			Thumbtack: lets you remove the pinned status to set the note back to RIGID_BODY mode
	At the top of the screen, there are a few icons:
		Save/Load
		Arrange:
			lets you rearrange the nodes by various attributes:
				Original Structure - how you assembled the nodes
				Tag - grouped around tags you've assigned
				Assignee
				Priority (essential, urgent, routine, trivial)
				Label
				Date (due date)
				Progress (todo, doing, done)


Bugs: 

	- when you create a note, it moves down right away. should move up?
	- saving / loading is broken
	
	

Features Required / User Stories:



Game Feel / UX Improvements:
	- when you spawn a new note, the camera should move to that note.


"""



extends Node

