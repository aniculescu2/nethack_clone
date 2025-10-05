class_name Mob
extends Actor2D

func _ready() -> void:
	element_type = Element2D.CellType.ACTOR
	element_id = 0
	alternative_id = 1
	alignment = ACTOR_ALIGNMENT.ENEMY
