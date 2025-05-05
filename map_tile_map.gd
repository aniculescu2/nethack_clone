extends TileMapLayer

const CELL_SIZE = Vector2i(64, 64)

enum State {IDLE, FOLLOW}

signal move_signal

# The object for pathfinding on 2D grids.
var _astar = AStarGrid2D.new()

var _start_point = Vector2i()
var _end_point = Vector2i()
var _path = PackedVector2Array()
var visited = []
var in_sight = []
var following_state = State.IDLE

func _ready() -> void:
	# Initialize the tile map layer
	for child in get_children():
		if child is Node2D:
			set_cell(local_to_map(child.position), child.element_id, Vector2i.ZERO)

	var mapRect: Rect2i = get_used_rect()
	for x in range(mapRect.position.x, mapRect.end.x):
		for y in range(mapRect.position.y, mapRect.end.y):
			var current = Vector2i(x, y)
			var tile_id = get_cell_source_id(current)
			set_cell(current, tile_id, Vector2i.ZERO, 2)
	update_light(local_to_map(%Player.position))
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
			print("pos", pos)
			var tile_data = get_cell_tile_data(pos)
			if tile_data:
				var element_id = tile_data.get_custom_data("Element_ID")
				if element_id == Element2D.CellType.WALL || element_id == Element2D.CellType.LOCKED_DOOR:
					_astar.set_point_solid(pos)


func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		var mouse_position = get_local_mouse_position()
		move_to(get_follow_path(mouse_position))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("move_right"):
		move(%Player, Vector2i.RIGHT)
		following_state = State.IDLE
	if event.is_action_released("move_left"):
		move(%Player, Vector2i.LEFT)
		following_state = State.IDLE
	if event.is_action_released("move_up"):
		move(%Player, Vector2i.UP)
		following_state = State.IDLE
	if event.is_action_released("move_down"):
		move(%Player, Vector2i.DOWN)
		following_state = State.IDLE
	if event.is_action_released("cancel"):
		following_state = State.IDLE
		clear_path()

func clear_path():
	if not _path.is_empty():
		_path.clear()

func get_follow_path(target_position):
	clear_path()

	_start_point = local_to_map(%Player.position)
	_end_point = local_to_map(target_position)
	_path = _astar.get_point_path(_start_point, _end_point, true)
	print(_path)
	return _path.duplicate()

func move_to(follow_path):
	following_state = State.FOLLOW
	for point in follow_path:
		if following_state == State.FOLLOW:
			var next_position = local_to_map(point)
			var start_position = local_to_map(%Player.position)
			var direction: Vector2i = Vector2i.ZERO
			if next_position.x > start_position.x:
				direction += Vector2i.RIGHT
			elif next_position.x < start_position.x:
				direction += Vector2i.LEFT
			if next_position.y < start_position.y:
				direction += Vector2i.UP
			elif next_position.y > start_position.y:
				direction += Vector2i.DOWN
			if not move(%Player, direction):
				following_state = State.IDLE
		else:
			break
		await get_tree().create_timer(.5).timeout
	following_state = State.IDLE


func move(node: Node2D, direction: Vector2i) -> bool:
	var start = local_to_map(node.position)
	var target = start + direction
	var tile_id = get_cell_source_id(target)
	match tile_id:
		Element2D.CellType.WALL:
			return false
		_:
			move_signal.emit(node, target)
			update_light(target)
			return true


func update_light(target: Vector2i) -> void:
	# Search adjacent tiles and lighten color modulation
	# Use BFS to find adjacent tiles and hit walls
	var queue = []
	for tile in in_sight:
		if not visited.has(tile):
			visited.append(tile)
	in_sight = []
	queue.append(target)
	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		var tile_id: int = get_cell_source_id(current)
		var element_id: Element2D.CellType = get_cell_tile_data(current).get_custom_data("Element_ID")

		# If any wall tiles between current and target, don't change cell
		if element_id != Element2D.CellType.WALL:
			var is_covered = false

			var m: float = 0.0
			var increment = 0
			if target.x != current.x:
				m = ((target.y - current.y) * 1.0) / ((target.x - current.x) * 1.0)

				if current.x > target.x:
					increment = -2
				else:
					increment = 2
				for x in range(current.x * 10.0, target.x * 10.0, increment):
					var y: float = -m * (target.x - (x / 10.0)) + target.y
					var line_cell = Vector2i(roundi(x / 10.0), roundi(y))
					if get_cell_source_id(line_cell) == Element2D.CellType.WALL:
						is_covered = true
						break
			else:
				# Iterate through y
				if current.y > target.y:
					increment = -1
				else:
					increment = 1
				for y in range(current.y, target.y, increment):
					if get_cell_source_id(Vector2i(target.x, y)) == Element2D.CellType.WALL:
						is_covered = true
						break

			if is_covered:
				continue

		in_sight.append(current)
		set_cell(current, tile_id, Vector2i.ZERO, 0)

		# Find neighboring tiles, if current is a wall, stop searching
		if element_id == Element2D.CellType.WALL:
			continue
		elif element_id == Element2D.CellType.DOOR:
			continue
		for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
			var neighbor = current + direction
			if not in_sight.has(neighbor):
				queue.append(neighbor)

	# Remove tiles that are not in sight
	var erased = true
	while erased:
		erased = false
		for tile in visited:
			if tile in in_sight:
				visited.erase(tile)
				erased = true
				continue

	for current in visited:
		var tile_id = get_cell_source_id(current)
		set_cell(current, tile_id, Vector2i.ZERO, 1)
