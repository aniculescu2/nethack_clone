extends TileMapLayer

var tile_id = -1

var object_dict = {}

func _ready() -> void:
	# Initialize the tile map layer
	for child in get_children():
		if child is Node2D:
			# Set the cell for each child element
			# TODO: Use different potion sprites based on potion type
			# if child is Potion:
			#     var alternate_tile = child.potion_type
			set_cell(local_to_map(child.position), child.element_id, Vector2i.ZERO)
			object_dict[local_to_map(child.position)] = child

	$Player/Camera2D/CanvasLayer/GameUI.object_picked_up.connect(_on_game_ui_object_picked_up)

func move_element(element, target):
	var start = local_to_map(element.position)
	set_cell(start, tile_id, Vector2i.ZERO)
	var tile_on_spot = get_cell_tile_data(target)
	tile_id = get_cell_source_id(target)
	set_cell(target, element.element_id, Vector2i.ZERO)
	element.position = map_to_local(target)
	if element == $Player:
		if tile_on_spot and tile_on_spot.get_custom_data("Element_ID") == Element2D.CellType.ITEM:
			$Player/Camera2D/CanvasLayer/GameUI/PickUpButton.show()
		else:
			$Player/Camera2D/CanvasLayer/GameUI/PickUpButton.hide()

func _on_game_ui_object_picked_up() -> void:
	print("Object picked up")
	tile_id = -1
	$Player.add_to_inventory(object_dict[local_to_map($Player.position)])
	object_dict.erase($Player.position)
