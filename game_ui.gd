extends Control

signal object_picked_up

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
