class_name Element2D
extends Node2D

enum CellType {
	ACTOR, # Movable piece, like a player or NPC
	WALL, # Impassable object
	FLOOR, # Walkable area
	CLOSED_DOOR, # Can be opened
	OPEN_DOOR, # Can be walked through
	LOCKED_DOOR, # Can be opened with an action
	ITEM, # Can be picked up and walked over
}

enum ItemType {
	POTION = 1,
	KEY,
	GOLD,
	WEAPON,
	ARMOR,
}

@export var element_type: CellType
@export var element_id: int = -1 # Unique identifier for the element
@export var alternative_id: int = 0 # Alternative identifier for the element, if needed
@export var texture_path: String

func _use() -> bool:
	# This method should be overridden by subclasses to implement specific use behavior
	# Returns true if the element is used up and should be removed, false otherwise
	print("Using element: ", self.name)
	return false
