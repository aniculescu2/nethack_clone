extends Element2D

signal health_changed(health: int)

@onready var game_ui = $Camera2D/CanvasLayer/GameUI
@export var max_health: int = 30
var health: int:
	set(value):
		health = clamp(value, 0, max_health)
		game_ui._on_player_health_changed(health)

var inventory = []

func _ready() -> void:
	health = max_health # Initial health
	game_ui.get_node("StatusPanel/HealthBar").max_value = max_health
	game_ui.update_inventory(inventory)
	game_ui.use_item.connect(_on_use_item)
	GlobalSignals.increase_health.connect(increase_health)

func increase_health(amount: int) -> void:
	health += amount
	print("Health increased by: ", amount, " New health: ", health)

func add_to_inventory(item):
	inventory.append(item)
	game_ui.update_inventory(inventory)

func drop_item(index: int) -> void:
	inventory.remove_at(index)
	game_ui.update_inventory(inventory)

func _on_use_item(index: int) -> void:
	var item = inventory.pop_at(index)
	game_ui.update_inventory(inventory)
	if item:
		print("Using item: ", item.name)
		# Implement item use logic here, e.g., apply effects
		item.use()
	else:
		print("No item found at index: ", index)
