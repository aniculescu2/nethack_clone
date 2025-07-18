extends Node

@onready var map = $MapControl/MapTileMap

func _ready() -> void:
	map.move_signal.connect($ObjectTileMap.move_element)


func _process(_delta: float) -> void:
	pass
