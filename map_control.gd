extends Control

func _gui_input(event: InputEvent) -> void:
	$MapTileMap.handle_input(event)
