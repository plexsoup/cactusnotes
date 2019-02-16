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
	- nodes are spawning in static mode instead of character mode.
	

Game Feel / UX Improvements:
	- ctrl-n doesn't work on browser. change it to ctrl-space or ctrl-enter
	- add ctrl-left, ctrl-right, ctrl-up, ctrl-down to create new nodes in those directions
	
	
	- add a mechanism for players to connect new edges
	
	- notes should radiate away from the anchor-node.
	- add some extents to the map. Why can the magnifying glass fly infinietely away from the anchornode?
	
	- notes should try and occupy empty space. Maybe add a slight repulsion force to them.
	
Refactoring / Architecture Improvements:

"""



extends Node

