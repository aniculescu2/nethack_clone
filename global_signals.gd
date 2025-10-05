extends Node

# Global signals for the game

# Signal for anything that increases player health
signal increase_health(amount: int)

# Signal for any event that needs to update light, like moving or picking up an item
signal update_light(target: Vector2i)

# Signal for actor death
signal actor_died(actor: Actor2D)

# Signal for item dropped (e.g., when a mob dies)
signal item_dropped(item: Element2D)