extends TileMapLayer

var tile_on_spot = -1
func _ready() -> void:
	# Initialize the tile map layer
    for child in get_children():
        if child is Node2D:
            # Set the cell for each child element
            # TODO: Use different potion sprites based on potion type
            # if child is Potion:
            #     var alternate_tile = child.potion_type
            set_cell(local_to_map(child.position), child.element_id, Vector2i.ZERO)

func move_element(element, target):
    var start = local_to_map(element.position)
    set_cell(start, tile_on_spot, Vector2i.ZERO)
    tile_on_spot = get_cell_source_id(target)
    set_cell(target, element.element_id, Vector2i.ZERO)
    element.position = map_to_local(target)
    if element == $Player:
        $Player/Camera2D.position = Vector2(0, 0)