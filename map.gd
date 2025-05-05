extends Node


var visited = []
var in_sight = []

func _ready() -> void:
	$MapTileMap.move_signal.connect(update_light)


func _process(_delta: float) -> void:
	pass


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
		var current = queue.pop_front()
		var tile_id = $MapTileMap.get_cell_source_id(current)
		var back_tile_id = $BackgroundTileMap.get_cell_source_id(current)

		# If any wall tiles between current and target, don't change cell
		if tile_id != Element2D.CellType.WALL:
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
					if $MapTileMap.get_cell_source_id(line_cell) == Element2D.CellType.WALL:
						is_covered = true
						break
			else:
				# Iterate through y
				if current.y > target.y:
					increment = -1
				else:
					increment = 1
				for y in range(current.y, target.y, increment):
					if $MapTileMap.get_cell_source_id(Vector2i(target.x, y)) == Element2D.CellType.WALL:
						is_covered = true
						break

			if is_covered:
				continue

		in_sight.append(current)
		$MapTileMap.set_cell(current, tile_id, Vector2i.ZERO, 0)
		$BackgroundTileMap.set_cell(current, back_tile_id, Vector2i.ZERO, 0)

		# Find neighboring tiles, if current is a wall, stop searching
		if tile_id == Element2D.CellType.WALL:
			continue
		elif tile_id == Element2D.CellType.DOOR:
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
		var tile_id = $MapTileMap.get_cell_source_id(current)
		var back_tile_id = $BackgroundTileMap.get_cell_source_id(current)
		$MapTileMap.set_cell(current, tile_id, Vector2i.ZERO, 1)
		$BackgroundTileMap.set_cell(current, back_tile_id, Vector2i.ZERO, 1)
