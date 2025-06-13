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
	health = max_health
	game_ui.get_node("StatusPanel/HealthBar").max_value = max_health
	game_ui.update_inventory(inventory)

func add_to_inventory(item):
	inventory.append(item)
	game_ui.update_inventory(inventory)

func drop_item(index: int) -> void:
	inventory.remove_at(index)
	game_ui.update_inventory(inventory)
