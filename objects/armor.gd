class_name Armor
extends Element2D

@export var armor_value: int = 1
@export var slot: String = "body" # e.g., "head", "body", "legs", etc.

func _ready() -> void:
	element_id = Element2D.ItemType.ARMOR
	element_type = Element2D.CellType.ITEM
	match slot:
		"head":
			texture_path = "res://textures/helmet.png"
		"body":
			texture_path = "res://textures/chestplate.png"
		"legs":
			texture_path = "res://textures/leggings.png"
		"feet":
			texture_path = "res://textures/boots.png"

func _use() -> bool:
	# Armor is not consumed on use; it is equipped
	return true