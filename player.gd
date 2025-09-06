extends Element2D

signal health_changed(health: int)

@onready var game_ui = $Camera2D/CanvasLayer/GameUI
@export var max_health: int = 30
var health: int:
	set(value):
		health = clamp(value, 0, max_health)
		game_ui._on_player_health_changed(health)

var inventory = []

var equipment = {"head": null, "right_arm": null, "left_arm": null, "legs": null, "feet": null}

var gold: int:
	set(value):
		gold = max(value, 0) # Ensure gold cannot be negative
		game_ui._on_gold_changed(gold)

func _ready() -> void:
	element_type = Element2D.CellType.ACTOR
	element_id = 0 # Unique identifier for the player

	# Set health
	health = max_health # Initial health
	game_ui.get_node("StatusPanel/HBoxContainer/HealthBar").max_value = max_health
	game_ui.update_inventory(inventory)
	game_ui.use_item.connect(_on_use_item)
	game_ui.unequipped_item.connect(_on_unequipped_item)

	# Connect to global signal for health increase (e.g., from potions)
	GlobalSignals.increase_health.connect(increase_health)

func increase_health(amount: int) -> void:
	health += amount
	print("Health increased by: ", amount, " New health: ", health)

func add_to_inventory(item):
	if item is Gold:
		gold += item.amount
		print("Gold added: ", item.amount, " Total gold: ", gold)
	else:
		inventory.append(item)
		game_ui.update_inventory(inventory)

func remove_from_inventory(index: int) -> void:
	inventory.remove_at(index)
	game_ui.update_inventory(inventory)

func _on_use_item(index: int) -> void:
	var item = inventory.get(index)
	if item:
		print("Using item: ", item.name)
		# Implement item use logic here, e.g., apply effects
		var used: bool = item._use()
		var equip_index = ""
		print("element_id")
		print(item.element_id)
		match item.element_id:
			Element2D.ItemType.SWORD:
				equip_index = "right_arm"

		print("equip_index")
		print(equip_index)
		if equip_index != "":
			# Unequip whatever is equipped
			print("Checking equipment: ", equipment[equip_index])
			if equipment[equip_index]:
				print("Unequipping previous item from: ", equip_index)
				add_to_inventory(equipment[equip_index])
			equipment[equip_index] = item
			game_ui.update_equipment(equipment)

		if used:
			print("Item used and removed from inventory: ", item.name)
			remove_from_inventory(index)
			if not equip_index:
				item.queue_free() # Remove item from the game
		else:
			print("Item not used, remains in inventory: ", item.name)
	else:
		print("No item found at index: ", index)

func _on_unequipped_item(equip_index: String) -> void:
	if equipment.has(equip_index) and equipment[equip_index]:
		print("Unequipping item from: ", equip_index)
		add_to_inventory(equipment[equip_index])
		equipment[equip_index] = null
		game_ui.update_equipment(equipment)
	else:
		print("No item equipped in: ", equip_index)