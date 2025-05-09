extends TileMapLayer

var tile_on_spot = -1
func _ready() -> void:
	# Initialize the tile map layer
    for child in get_children():
        if child is Node2D:
            set_cell(local_to_map(child.position), child.element_id, Vector2i.ZERO)

func move_element(element, target):
    var start = local_to_map(element.position)
    tile_on_spot = get_cell_source_id(target)
    set_cell(target, element.element_id, Vector2i.ZERO)
    set_cell(start, tile_on_spot, Vector2i.ZERO)
    element.position = map_to_local(target)
    if element == $Player:
        $Player/Camera2D.position = Vector2(0, 0)