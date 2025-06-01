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

@export var element_id: CellType
@export var texture_path: String