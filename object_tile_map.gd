extends TileMapLayer

var tile_id = -1

# Dictionary to hold object references by their map position
# This allows for quick access to objects based on their position in the tile map
# The key is the map position (Vector2i), and the value is a list of objects at that position
var object_dict = {}

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
			set_cell(local_to_map(child.position), child.element_id, Vector2i.ZERO)
			if not object_dict.has(local_to_map(child.position)):
				object_dict[local_to_map(child.position)] = []
			object_dict[local_to_map(child.position)].append(child)

	game_ui.object_picked_up.connect(_on_game_ui_object_picked_up)
	game_ui.drop_item.connect(_on_game_ui_drop_item)

func move_element(element, target):
	var start = local_to_map(element.position)
	set_cell(start, tile_id, Vector2i.ZERO)
	var tile_on_spot = get_cell_tile_data(target)
	tile_id = get_cell_source_id(target)
	set_cell(target, element.element_id, Vector2i.ZERO)
	element.position = map_to_local(target)
	if element == player:
		if tile_on_spot and tile_on_spot.get_custom_data("Element_ID") == Element2D.CellType.ITEM:
			game_ui.get_node("PickUpButton").show()
		else:
			game_ui.get_node("PickUpButton").hide()

func _on_game_ui_object_picked_up() -> void:
	tile_id = -1
	for item in object_dict[local_to_map(player.position)]:
		player.add_to_inventory(item)
		remove_child(item)
		object_dict[local_to_map(player.position)].erase(item)

func _on_game_ui_drop_item(index: int) -> void:
	if index >= 0 and index < player.inventory.size():
		var item = player.inventory[index]
		print("Dropping item: ", item.name)
		print("item: ", item)
		if not item:
			print("Item is null, cannot drop.")
			return
		item.position = player.position
		tile_id = item.element_id
		object_dict[local_to_map(player.position)] = item
		add_child(item)
		player.drop_item(index)
		game_ui.get_node("PickUpButton").show()
