extends Element2D

signal health_changed(health: int)

@onready var game_ui = $Camera2D/CanvasLayer/GameUI
@export var max_health: int = 30
var health: int:
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health)

var inventory = []

func _ready() -> void:
	health_changed.connect(game_ui._on_player_health_changed)
	health = max_health
	$Camera2D/CanvasLayer/GameUI/StatusPanel/HealthBar.max_value = max_health


func add_to_inventory(item):
	inventory.append(item)
	item.queue_free() # Remove the item from the scene
	$Camera2D/CanvasLayer/GameUI.update_inventory(inventory)
