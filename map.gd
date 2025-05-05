extends Node


func _ready() -> void:
	$MapTileMap.move_signal.connect($ObjectTileMap.move_element)


func _process(_delta: float) -> void:
	pass
