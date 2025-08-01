extends Node

@onready var map = $MapControl/MapTileMap

func _ready() -> void:
	map.move_signal.connect($ObjectTileMap.move_element)
	map.light_updated.connect($ObjectTileMap.update_object_light)
	map.object_map_ready()


func _process(_delta: float) -> void:
	pass
