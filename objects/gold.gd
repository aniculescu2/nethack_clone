class_name Gold
extends Element2D

@export var amount: int = 0

func _ready() -> void:
	element_type = Element2D.CellType.ITEM
	element_id = Element2D.ItemType.GOLD
	texture_path = "res://textures/gold.png"