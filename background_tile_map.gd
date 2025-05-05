extends TileMapLayer
@onready var map: TileMapLayer = $"../MapTileMap"
func _ready() -> void:
	# Initialize the tile map layer
	for child in get_children():
		if child is Node2D:
			set_cell(local_to_map(child.position), 1, Vector2i.ZERO)

	var mapRect: Rect2i = get_used_rect()
	for x in range(mapRect.position.x, mapRect.end.x):
		for y in range(mapRect.position.y, mapRect.end.y):
			var current = Vector2i(x, y)
			var tile_id = get_cell_source_id(current)
			set_cell(current, tile_id, Vector2i.ZERO, 2)

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in map.get_used_cells_by_id(1):
		return true
	return false
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in map.get_used_cells_by_id(1):
		tile_data.set_navigation_polygon(0, null)
