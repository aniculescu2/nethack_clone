extends TileMapLayer

const CELL_SIZE = Vector2i(64, 64)

enum State {IDLE, FOLLOW}

signal move_signal
signal light_updated

# The object for pathfinding on 2D grids.
var _astar = AStarGrid2D.new()

var _start_point = Vector2i()
var _end_point = Vector2i()
var _path = PackedVector2Array()
var _visited = []
var _in_sight = []
var _following_state = State.IDLE
var _click_position: Vector2
var _next_point
var _dragging: bool

@onready var _player_node: Element2D = %Player
@onready var _camera_node: Camera2D = _player_node.get_node("Camera2D")

func _ready() -> void:
	# Initialize the tile map layer
	for child in get_children():
		if child is Element2D:
			set_cell(local_to_map(child.position), child.element_id, Vector2i.ZERO)

	var mapRect: Rect2i = get_used_rect()
	for x in range(mapRect.position.x, mapRect.end.x):
		for y in range(mapRect.position.y, mapRect.end.y):
			var current = Vector2i(x, y)
			var tile_id = get_cell_source_id(current)
			set_cell(current, tile_id, Vector2i.ZERO, 2)
	update_light(local_to_map(_player_node.position))
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
			var tile_data = get_cell_tile_data(pos)
			if tile_data:
				var element_id = tile_data.get_custom_data("Element_ID")
				if element_id == Element2D.CellType.WALL || element_id == Element2D.CellType.LOCKED_DOOR:
					_astar.set_point_solid(pos)

	GlobalSignals.update_light.connect(update_light)

func handle_input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_double_click():
					_click_position = get_local_mouse_position()
					_change_state(State.FOLLOW)
					start_path()
			MOUSE_BUTTON_WHEEL_UP:
				var current_zoom = _camera_node.zoom
				if current_zoom < Vector2(2, 2):
					_camera_node.zoom = current_zoom + Vector2(.3, .3)
			MOUSE_BUTTON_WHEEL_DOWN:
				var current_zoom = _camera_node.zoom
				if current_zoom >= Vector2(.3, .3):
					_camera_node.zoom = current_zoom - Vector2(.3, .3)

	elif event is InputEventMouseMotion and event.pressure:
		_dragging = true
		_camera_node.position -= event.relative

	_dragging = false


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("move_right"):
		move(_player_node, Vector2i.RIGHT)
		_following_state = State.IDLE
	if event.is_action_released("move_left"):
		move(_player_node, Vector2i.LEFT)
		_following_state = State.IDLE
	if event.is_action_released("move_up"):
		move(_player_node, Vector2i.UP)
		_following_state = State.IDLE
	if event.is_action_released("move_down"):
		move(_player_node, Vector2i.DOWN)
		_following_state = State.IDLE
	if event.is_action_released("cancel"):
		clear_path()

func start_path() -> void:
	while (_following_state == State.FOLLOW):
		highlight_tile(local_to_map(_path[-1]), true)
		var arrived_to_next_point = move_to(_player_node, _next_point)
		highlight_tile(local_to_map(_path[-1]), true)
		await get_tree().create_timer(.5).timeout
		if arrived_to_next_point:
			_path.remove_at(0)
			if _path.is_empty():
				clear_path()
				return
			_next_point = _path[0]
		else:
			clear_path()
			# ai_round()

func clear_path():
	if not _path.is_empty():
		highlight_tile(local_to_map(_path[-1]), false)
		_path.clear()
	_following_state = State.IDLE

func _change_state(new_state):
	if new_state == State.IDLE:
		clear_path()
	elif new_state == State.FOLLOW:
		_path = get_follow_path(_click_position)
		if _path.size() < 2:
			_change_state(State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		_next_point = _path[1]
	_following_state = new_state

func get_follow_path(target_position):
	clear_path()

	_start_point = local_to_map(_player_node.position)
	_end_point = local_to_map(target_position)
	_path = _astar.get_point_path(_start_point, _end_point, true)
	return _path.duplicate()

func highlight_tile(tile_position, flag):
	var tile_id = get_cell_source_id(tile_position)
	if flag:
		set_cell(tile_position, tile_id, Vector2i.ZERO, 3)
	else:
		set_cell(tile_position, tile_id, Vector2i.ZERO, 0)

func move_to(node: Element2D, target: Vector2i) -> bool:
	var next_position = local_to_map(target)
	var start_position = local_to_map(node.position)
	var direction: Vector2i = Vector2i.ZERO
	if next_position.x > start_position.x:
		direction += Vector2i.RIGHT
	elif next_position.x < start_position.x:
		direction += Vector2i.LEFT
	if next_position.y < start_position.y:
		direction += Vector2i.UP
	elif next_position.y > start_position.y:
		direction += Vector2i.DOWN
	return move(node, direction)

func move(node: Element2D, direction: Vector2i) -> bool:
	var start = local_to_map(node.position)
	var target = start + direction
	var element_id = get_cell_tile_data(target).get_custom_data("Element_ID")
	match element_id:
		Element2D.CellType.WALL:
			return false
		Element2D.CellType.LOCKED_DOOR:
			# Check type of door (alternative tile)
			var door_type: int = get_cell_alternative_tile(target)
			var is_unlocked = unlock_door(node, door_type)
			if is_unlocked:
				open_door(target)
				update_light(start)
			return is_unlocked
		Element2D.CellType.CLOSED_DOOR:
			open_door(target)
			move_signal.emit(node, target)
			update_light(target)
			return true
		_:
			move_signal.emit(node, target)
			update_light(target)
			return true

## Opens a door at the specified target position and updates navigation
func open_door(target: Vector2i) -> void:
	set_cell(target, 0, Vector2i.ZERO, 0)
	_astar.set_point_solid(target, false)

func unlock_door(node: Element2D, door_type: int) -> bool:
	# Check if the player has the key to unlock the door
	if node.element_id == Element2D.CellType.ACTOR and node.inventory.size() > 0:
		for item in node.inventory:
			if item is Key and item.door_key == door_type:
				print("Door unlocked with key: ", item.name)
				node.remove_item(node.inventory.find(item)) # Remove the key from inventory
				return true
	print("No key found to unlock the door.")
	return false

func update_light(target: Vector2i) -> void:
	# Search adjacent tiles and lighten color modulation
	# Use BFS to find adjacent tiles and hit walls
	var queue = []
	for tile in _in_sight:
		if not _visited.has(tile):
			_visited.append(tile)
	_in_sight = []
	queue.append(target)
	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()
		var tile_id: int = get_cell_source_id(current)
		var element_id: Element2D.CellType = get_cell_tile_data(current).get_custom_data("Element_ID")
		var is_closed = element_id == Element2D.CellType.CLOSED_DOOR or element_id == Element2D.CellType.LOCKED_DOOR or element_id == Element2D.CellType.WALL
		# If any wall tiles between current and target, don't change cell
		if not is_closed:
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
					var y: float = (-m * (target.x - (x / 10.0))) + target.y
					var line_cell = Vector2i(roundi(x / 10.0), roundi(y))
					var cell_id = get_cell_tile_data(line_cell).get_custom_data("Element_ID")
					if cell_id == Element2D.CellType.WALL or cell_id == Element2D.CellType.CLOSED_DOOR or cell_id == Element2D.CellType.LOCKED_DOOR:
						is_covered = true
						break

				# Iterate through y
				if current.y > target.y:
					increment = -1
				else:
					increment = 1
				for y in range(current.y, target.y, increment):
					var cell_id = get_cell_tile_data(Vector2i(target.x, y)).get_custom_data("Element_ID")
					if cell_id == Element2D.CellType.WALL or cell_id == Element2D.CellType.CLOSED_DOOR or cell_id == Element2D.CellType.LOCKED_DOOR:
						is_covered = true
						break

			if is_covered:
				continue

		_in_sight.append(current)
		set_cell(current, tile_id, Vector2i.ZERO, 0)
		#Todo: remove items if not in _in_sight

		if is_closed:
			# If the current tile is a wall, stop searching
			continue

		# Find neighboring tiles, if current is a wall, stop searching
		for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN, Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
			var neighbor = current + direction
			if not _in_sight.has(neighbor):
				queue.append(neighbor)

	# Remove tiles that are not in sight
	var erased = true
	while erased:
		erased = false
		for tile in _visited:
			if tile in _in_sight:
				_visited.erase(tile)
				erased = true
				continue

	for current in _visited:
		var tile_id = get_cell_source_id(current)
		set_cell(current, tile_id, Vector2i.ZERO, 1)

	light_updated.emit(_in_sight)

#
func object_map_ready():
	update_light(local_to_map(_player_node.position))
