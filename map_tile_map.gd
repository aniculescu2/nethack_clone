extends TileMapLayer

signal move_signal

var tile_on_spot = -1

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

func _process(delta: float) -> void:
	if Input.is_action_just_released("move_right"):
		move($Player, Vector2i.RIGHT)
	if Input.is_action_just_released("move_left"):
		move($Player, Vector2i.LEFT)
	if Input.is_action_just_released("move_up"):
		move($Player, Vector2i.UP)
	if Input.is_action_just_released("move_down"):
		move($Player, Vector2i.DOWN)

func move_to(follow_path):
	for point in follow_path:
		var next_position = local_to_map(point)
		var start_position = local_to_map($Player.position)
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
			break
		await get_tree().create_timer(.5).timeout


func move(node: Node2D, direction: Vector2i) -> bool:
	var start = local_to_map(node.position)
	var target = start + direction
	var tile_id = get_cell_source_id(target)
	match tile_id:
		Element2D.CellType.WALL:
			return false
		_:
			set_cell(target, Element2D.CellType.ACTOR, Vector2i.ZERO)
			set_cell(start, tile_on_spot, Vector2i.ZERO)
			tile_on_spot = tile_id
			node.position = map_to_local(target)
			move_signal.emit(target)
			return true
