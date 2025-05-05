class_name Element2D
extends Node2D

enum CellType {
    ACTOR,
    WALL,
    FLOOR,
    DOOR,
    LOCKED_DOOR,
}

@export var element_id: CellType