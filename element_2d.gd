class_name Element2D
extends Node2D

enum CellType {
    ACTOR,
    WALL,
    FLOOR,
    CLOSED_DOOR,
    OPEN_DOOR,
    LOCKED_DOOR,
}

@export var element_id: CellType