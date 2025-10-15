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

func take_turn() -> void:
	print(name, " is taking its turn.")
	print("mob alignment: ", alignment)
	var init_pos = position
	var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	directions.shuffle()
	var player_distance = %Player.position - position
	match player_distance:
		Vector2(64, 0), Vector2(-64, 0), Vector2(0, 64), Vector2(0, -64):
			print(name, " is adjacent to player and will attack.")
			_move(player_distance.sign())
		_:
			while position == init_pos:
				if directions.is_empty():
					print(name, " has no valid moves and will skip its turn.")
					break
				# Try moving in a random direction
				var dir = directions.pop_back()
				_move(dir)
