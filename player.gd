extends Actor2D

signal health_changed(health: int)

@onready var game_ui = $Camera2D/CanvasLayer/GameUI


func _health_setter(value):
		health = clamp(value, 0, max_health)
		game_ui._on_player_health_changed(health)

func _gold_setter(value):
		gold = max(value, 0) # Ensure gold cannot be negative
		game_ui._on_gold_changed(gold)

func _ready() -> void:
	element_type = Element2D.CellType.ACTOR
	element_id = 0
	alternative_id = 0
	alignment = ACTOR_ALIGNMENT.FRIENDLY

	# Set health
	health = max_health # Initial health
	game_ui.get_node("StatusPanel/HBoxContainer/HealthBar").max_value = max_health
	game_ui.update_inventory(inventory)
	game_ui.use_item.connect(_on_use_item)
	game_ui.unequipped_item.connect(_on_unequipped_item)

	# Connect to global signal for health increase (e.g., from potions)
	GlobalSignals.increase_health.connect(_increase_health)

func _add_to_inventory(item):
	if item is Gold:
		gold += item.amount
		print("Gold added: ", item.amount, " Total gold: ", gold)
	else:
		inventory.append(item)
		game_ui.update_inventory(inventory)

func _remove_from_inventory(index: int) -> void:
	inventory.remove_at(index)
	game_ui.update_inventory(inventory)

func _update_equipment() -> void:
	game_ui.update_equipment(equipment)

func _on_unequipped_item(equip_index: String) -> void:
	if equipment.has(equip_index) and equipment[equip_index]:
		print("Unequipping item from: ", equip_index)
		_add_to_inventory(equipment[equip_index])
		equipment[equip_index] = null
		game_ui.update_equipment(equipment)
	else:
		print("No item equipped in: ", equip_index)
