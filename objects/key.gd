class_name Key
extends Element2D

@export var door_key: int = 0

func _ready() -> void:
	element_type = Element2D.CellType.ITEM
	element_id = Element2D.ItemType.KEY
	texture_path = "res://textures/key_small.png"