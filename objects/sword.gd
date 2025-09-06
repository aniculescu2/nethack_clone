class_name Sword
extends Element2D

@export var damage: int

func _ready() -> void:
	print("setting sword vars")
	element_id = Element2D.ItemType.SWORD
	element_type = Element2D.CellType.ITEM
	texture_path = "res://textures/sword.png"
	print(element_id)

func _use():
	return true
