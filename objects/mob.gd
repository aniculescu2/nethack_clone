class_name Mob
extends Actor2D

@export var gold_drop: int = 5

func _ready() -> void:
	element_type = Element2D.CellType.ACTOR
	element_id = 0
	alternative_id = 1
	alignment = ACTOR_ALIGNMENT.ENEMY
	# Set health
	health = max_health # Initial health

func _die() -> void:
	print(name, " has died.")
	# Additional logic for when the mob dies (e.g., play animation, drop loot)
	if gold_drop > 0:
		var gold_item = Gold.new()
		gold_item.amount = gold_drop
		gold_item.position = position
		GlobalSignals.item_dropped.emit(gold_item)
		print(name, " dropped ", gold_drop, " gold.")
	GlobalSignals.actor_died.emit(self)
	queue_free() # Remove the mob from the game
