extends TileMapLayer
@onready var map: TileMapLayer = $"../MapTileMap"

const CELL_SIZE = Vector2i(64, 64)

enum State {IDLE, FOLLOW}

# The object for pathfinding on 2D grids.
var _astar = AStarGrid2D.new()

var _start_point = Vector2i()
var _end_point = Vector2i()
var _path = PackedVector2Array()

signal move_path

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

	_astar.region = Rect2i(0, 0, mapRect.end.x + 1, mapRect.end.y + 1)
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	_astar.update()

	for i in range(_astar.region.position.x, _astar.region.end.x):
		for j in range(_astar.region.position.y, _astar.region.end.y):
			var pos = Vector2i(i, j)
			if get_cell_source_id(pos) != 0:
				_astar.set_point_solid(pos)

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		var mouse_position = get_local_mouse_position()
		move_path.emit(move_to(mouse_position))


func clear_path():
	if not _path.is_empty():
		_path.clear()


func move_to(target_position):
	clear_path()

	_start_point = local_to_map(%Player.position)
	_end_point = local_to_map(target_position)
	_path = _astar.get_point_path(_start_point, _end_point, true)
	return _path.duplicate()
