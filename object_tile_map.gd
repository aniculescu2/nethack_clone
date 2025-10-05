extends TileMapLayer

var tile_id = -1

# Dictionary to hold object references by their map position
# This allows for quick access to objects based on their position in the tile map
# The key is the map position (Vector2i), and the value is a list of objects at that position
var object_dict = {}

# Dictionary to hold actor references
# The key is the map position (Vector2i), and the value is the actor at that position
# Only one actor can be on a tile at a time
var actor_dict = {}

@onready var player = $Player
@onready var game_ui = $Player/Camera2D/CanvasLayer/GameUI

func _ready() -> void:
	# Initialize the tile map layer
	for child in get_children():
		if child is Node2D:
			# Set the cell for each child element
			# TODO: Use different potion sprites based on potion type
			# if child is Potion:
			#     var alternate_tile = child.potion_type
			if child.element_type == Element2D.CellType.ITEM:
				if not object_dict.has(local_to_map(child.position)):
					object_dict[local_to_map(child.position)] = []
				object_dict[local_to_map(child.position)].append(child)
			elif child.element_type == Element2D.CellType.ACTOR:
				actor_dict[local_to_map(child.position)] = child

	game_ui.all_objects_picked_up.connect(_on_game_ui_object_picked_up)
	game_ui.object_picked_up.connect(_on_floor_object_picked_up)
	game_ui.drop_item.connect(_on_game_ui_drop_item)
	GlobalSignals.actor_died.connect(_on_actor_died)
	GlobalSignals.item_dropped.connect(_on_mob_drop)

func move_element(element, target):
	# Check if target position is occupied by another actor
	if actor_dict.has(target) and actor_dict[target] != null:
		print("Target position occupied by another actor. Move aborted.")
		if element.alignment == Actor2D.ACTOR_ALIGNMENT.FRIENDLY and actor_dict[target].alignment == Actor2D.ACTOR_ALIGNMENT.ENEMY:
			print("Initiating attack on enemy at target position.")
			element._attack(actor_dict[target])
		return

	var start = local_to_map(element.position)
	set_cell(start, tile_id, Vector2i.ZERO)
	var tile_on_spot = get_cell_tile_data(target)
	tile_id = get_cell_source_id(target)
	set_cell(target, element.element_id, Vector2i.ZERO)
	element.position = map_to_local(target)

	# Check if item is on tile
	if element == player:
		var is_item: bool = false
		if tile_on_spot and object_dict.has(target):
			for item in object_dict[target]:
				if item.element_type == Element2D.CellType.ITEM:
					is_item = true
					break
		if is_item:
			# Show the pickup button if there are items on the tile
			game_ui.get_node("PickUpButton").show()
		else:
			# Hide the pickup button if there are no items
			game_ui.get_node("PickUpButton").hide()

		# Update floor dict to show items on the current tile
		if object_dict.has(target):
			game_ui.set_floor(object_dict[target])
		else:
			game_ui.set_floor([])

func _on_game_ui_object_picked_up() -> void:
	tile_id = -1
	print("items: ", object_dict[local_to_map(player.position)])
	for item in object_dict[local_to_map(player.position)]:
		print("Picking up item: ", item.name)
		player._add_to_inventory(item)
		remove_child(item)
	object_dict[local_to_map(player.position)] = []

func _on_game_ui_drop_item(index: int) -> void:
	var player_position = local_to_map(player.position)
	if index >= 0 and index < player.inventory.size():
		var item = player.inventory[index]
		print("Dropping item: ", item.name)
		print("item: ", item)
		if not item:
			print("Item is null, cannot drop.")
			return
		item.position = player.position
		tile_id = item.element_id
		if not object_dict.has(player_position):
			object_dict[player_position] = []
		object_dict[player_position].append(item)
		add_child(item)
		player._remove_from_inventory(index)
		game_ui.get_node("PickUpButton").show()

func _on_floor_object_picked_up(index) -> void:
	var player_position = local_to_map(player.position)
	if index >= 0 and index < object_dict[player_position].size():
		var item = object_dict[player_position][index]
		print("Picking up item from floor: ", item.name)
		player._add_to_inventory(item)
		remove_child(item)
		object_dict[player_position].remove_at(index)
		# Set tile_id to next item if available
		if object_dict[player_position].size() > 0:
			tile_id = object_dict[player_position][0].element_id
		else:
			tile_id = -1
			game_ui.get_node("PickUpButton").hide()
	else:
		print("Invalid item selected to pick up")

# Items are hidden until in line of sight of player
func update_object_light(in_sight):
	for loc in in_sight:
		if object_dict.has(loc) and not object_dict[loc].is_empty():
				if loc != local_to_map(player.position):
					set_cell(loc, object_dict[loc][0].element_id, Vector2i(object_dict[loc][0].alternative_id, 0))
		if actor_dict.has(loc) and actor_dict[loc]:
			if loc != local_to_map(player.position) and actor_dict[loc].alternative_id != 0:
				set_cell(loc, actor_dict[loc].element_id, Vector2i(actor_dict[loc].alternative_id, 0))

	set_cell(local_to_map(player.position), player.element_id, Vector2i.ZERO)

func _on_actor_died(actor: Actor2D) -> void:
	var actor_pos = local_to_map(actor.position)
	if actor_dict.has(actor_pos) and actor_dict[actor_pos] == actor:
		actor_dict[actor_pos] = null
		remove_child(actor)
		set_cell(actor_pos, -1, Vector2i.ZERO)
		print("Actor removed from tile map at position: ", actor_pos)

# Utility function to handle adding items to map
func _on_mob_drop(item: Element2D) -> void:
	var item_pos = local_to_map(item.position)
	if not object_dict.has(item_pos):
		object_dict[item_pos] = []
	object_dict[item_pos].append(item)
	add_child(item)
	print("Mob dropped item: ", item.name, " at position: ", item.position)
	set_cell(item.position, item.element_id, Vector2i.ZERO)
	# game_ui.get_node("PickUpButton").show()
