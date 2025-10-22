extends Control

signal all_objects_picked_up
signal object_picked_up
signal drop_item(index: int)
signal use_item(index: int)
signal unequipped_item(equip_index: String)

var selected_index: int = -1
var equip_index: String = ""

func _ready() -> void:
	$PickUpButton.hide()
	$InventoryPanel.hide()
	$FloorPanel.hide()
	$ItemUsePanel.hide()
	$EquipUsePanel.hide()
	$FloorUsePanel.hide()
	$EquipPanel.hide()
	$StatusPanel/HBoxContainer/GoldLabel.text = "0"

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		_on_inventory_button_pressed()
	elif event.is_action_pressed("pick_up_object"):
		_on_pick_up_button_pressed()

func _on_inventory_button_pressed() -> void:
	if $InventoryPanel.visible:
		$InventoryPanel.hide()
		$ItemUsePanel.hide()
		selected_index = -1
	else:
		$InventoryPanel.show()

func _on_pick_up_button_pressed() -> void:
	$PickUpButton.hide()
	all_objects_picked_up.emit()
	$FloorPanel/FloorList.clear()
	GlobalSignals.end_player_turn.emit()

func _on_floor_button_pressed() -> void:
	if $FloorPanel.visible:
		$FloorPanel.hide()
	else:
		$FloorPanel.show()

# Updates visual item list
# Should be called after every time inventory is modified
func update_inventory(inventory: Array) -> void:
	$InventoryPanel/InventoryList.clear()
	for item in inventory:
		var item_texture = load(item.texture_path)
		$InventoryPanel/InventoryList.add_item(item.name, item_texture)

func update_equipment(equipment: Dictionary) -> void:
	var equip_textures = {}
	for key in equipment.keys():
		if equipment[key] and equipment[key].texture_path:
			equip_textures[key] = load(equipment[key].texture_path)
		else:
			equip_textures[key] = null
	var equip_panel = $EquipPanel/Panel
	for part in equipment.keys():
		var button_name: String = part
		button_name[0] = button_name[0].to_upper()
		# Turn part name into button name, e.g., "right_arm" -> "RightArmButton", only works for one underscore
		for i in range(button_name.length()):
			if button_name[i] == "_":
				button_name = button_name.substr(0, i) + button_name[i + 1].to_upper() + button_name.substr(i + 2)
				break
		button_name += "Button"
		equip_panel.get_node(button_name).get_node("TextureRect").texture = equip_textures.get(part, null)
		equip_panel.get_node(button_name).tooltip_text = equipment.get(part, null).name if equipment.get(part, null) else "Empty"


func _on_player_health_changed(health: int) -> void:
	$StatusPanel/HBoxContainer/HealthBar.set_value_no_signal(health)
	if health <= 0:
		$StatusPanel/HBoxContainer/HealthBar.set_value_no_signal(0)

func _on_inventory_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		selected_index = -1
		$ItemUsePanel.hide()

func _on_use_button_pressed() -> void:
	if selected_index != -1:
		print("Using item at index: ", selected_index)
		# Implement item use logic here
		# $InventoryPanel/InventoryList.remove_item(selected_index)
		use_item.emit(selected_index)
		GlobalSignals.end_player_turn.emit()
	else:
		print("No item selected to use")
	selected_index = -1
	$ItemUsePanel.hide()

func _on_drop_button_pressed() -> void:
	if selected_index != -1:
		# Implement item drop logic here
		$FloorPanel/FloorList.add_item($InventoryPanel/InventoryList.get_item_text(selected_index), $InventoryPanel/InventoryList.get_item_icon(selected_index))
		$InventoryPanel/InventoryList.remove_item(selected_index)
		drop_item.emit(selected_index)
		GlobalSignals.end_player_turn.emit()
	else:
		print("No item selected to drop")
	selected_index = -1
	$ItemUsePanel.hide()

func _on_inventory_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		selected_index = index
		$ItemUsePanel.position = get_viewport().get_mouse_position()
		$ItemUsePanel.show()
		$ItemUsePanel.grab_focus()

func set_floor(item_list):
	$FloorPanel/FloorList.clear()
	for item in item_list:
		var item_texture = load(item.texture_path)
		$FloorPanel/FloorList.add_item(item.name, item_texture)

func _on_floor_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		selected_index = index
		$FloorUsePanel.position = get_viewport().get_mouse_position()
		$FloorUsePanel.show()
		$FloorUsePanel.grab_focus()

func _on_floor_pick_up_button_pressed() -> void:
	if selected_index != -1:
		print("Picking up item at index: ", selected_index)
		# Implement item pick up logic here
		$FloorPanel/FloorList.remove_item(selected_index)
		object_picked_up.emit(selected_index)
		GlobalSignals.end_player_turn.emit()

	else:
		print("No item selected to pick up")
	selected_index = -1
	$FloorUsePanel.hide()

func _on_floor_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		selected_index = -1
		$FloorUsePanel.hide()

func _on_gold_changed(new_gold: int) -> void:
	$StatusPanel/HBoxContainer/GoldLabel.text = "%d" % new_gold

func _on_equip_button_pressed() -> void:
	if $EquipPanel.visible:
		$EquipPanel.hide()
		$ItemUsePanel.hide()
	else:
		$EquipPanel.show()

func _on_head_button_pressed() -> void:
	if $EquipPanel/Panel/HeadButton/TextureRect.texture == null:
		print("No item equipped in head")
	else:
		equip_index = "head"
		$EquipUsePanel.position = $EquipPanel/Panel/HeadButton.global_position
		$EquipUsePanel.show()
		$EquipUsePanel.grab_focus()

func _on_right_arm_button_pressed() -> void:
	if $EquipPanel/Panel/RightArmButton/TextureRect.texture == null:
		print("No item equipped in right arm")
	else:
		equip_index = "right_arm"
		$EquipUsePanel.position = $EquipPanel/Panel/RightArmButton.global_position
		$EquipUsePanel.show()
		$EquipUsePanel.grab_focus()

func _on_left_arm_button_pressed() -> void:
	if $EquipPanel/Panel/LeftArmButton/TextureRect.texture == null:
		print("No item equipped in left arm")
	else:
		equip_index = "left_arm"
		$EquipUsePanel.position = $EquipPanel/Panel/LeftArmButton.global_position
		$EquipUsePanel.show()
		$EquipUsePanel.grab_focus()

func _on_legs_button_pressed() -> void:
	if $EquipPanel/Panel/LegsButton/TextureRect.texture == null:
		print("No item equipped in legs")
	else:
		equip_index = "legs"
		$EquipUsePanel.position = $EquipPanel/Panel/LegsButton.global_position
		$EquipUsePanel.show()
		$EquipUsePanel.grab_focus()

func _on_feet_button_pressed() -> void:
	if $EquipPanel/Panel/FeetButton/TextureRect.texture == null:
		print("No item equipped in feet")
	else:
		equip_index = "feet"
		$EquipUsePanel.position = $EquipPanel/Panel/FeetButton.global_position
		$EquipUsePanel.show()
		$EquipUsePanel.grab_focus()

func _on_unequip_button_pressed() -> void:
	if equip_index == "":
		print("No item equipped")
	else:
		unequipped_item.emit(equip_index)
		equip_index = ""
		$EquipUsePanel.hide()
		GlobalSignals.end_player_turn.emit()

func _on_equip_panel_panel_gui_input(event: InputEvent) -> void:
	$EquipUsePanel.hide()
