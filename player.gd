extends Element2D

var inventory = []

func add_to_inventory(item):
    inventory.append(item)
    item.queue_free() # Remove the item from the scene
    $Camera2D/CanvasLayer/GameUI.update_inventory(inventory)