extends Control

signal object_picked_up
signal drop_item(index: int)

var selected_index: int = -1

func _ready() -> void:
	$PickUpButton.hide()
	$InventoryPanel.hide()

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
	object_picked_up.emit()
	print("Object picked up signal emitted")

func update_inventory(inventory: Array) -> void:
	$InventoryPanel/InventoryList.clear()
	for item in inventory:
		var item_texture = load(item.texture_path)
		$InventoryPanel/InventoryList.add_item(item.name, item_texture)

func _on_player_health_changed(health: int) -> void:
	$StatusPanel/HealthBar.set_value_no_signal(health)
	if health <= 0:
		$StatusPanel/HealthBar.set_value_no_signal(0)
		print("Player has died")
		# Handle player death logic here, e.g., show game over screen

func _on_inventory_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		selected_index = -1
		$ItemUsePanel.hide()

func _on_use_button_pressed() -> void:
	if selected_index != -1:
		print("Using item at index: ", selected_index)
		# Implement item use logic here
	else:
		print("No item selected to use")
	selected_index = -1
	$ItemUsePanel.hide()

func _on_drop_button_pressed() -> void:
	if selected_index != -1:
		print("Dropping item at index: ", selected_index)
		# Implement item drop logic here
		$InventoryPanel/InventoryList.remove_item(selected_index)
		drop_item.emit(selected_index)
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
