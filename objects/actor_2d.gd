class_name Actor2D
extends Element2D

enum ACTOR_ALIGNMENT {
	FRIENDLY,
	NEUTRAL,
	ENEMY
}

@export var max_health: int = 10

var health: int:
	set = _health_setter

func _health_setter(value):
	if health == 0:
		print(name, " is already dead. Health cannot be changed.")
		print("WARNING: Make sure health was initiallly set in _ready()")
	health = clamp(value, 0, max_health)
	if health <= 0:
		_die()

# Player strength attribute, could influence damage, carrying capacity, etc.
var strength: int:
	set = _strength_setter
func _strength_setter(value):
		strength = max(value, 0)

var armor: int = 0 # Damage reduction from armor

var inventory = []

var equipment = {"head": null, "right_arm": null, "left_arm": null, "legs": null, "feet": null}

var gold: int:
	set = _gold_setter
func _gold_setter(value):
		gold = max(value, 0) # Ensure gold cannot be negative

var alignment: ACTOR_ALIGNMENT = ACTOR_ALIGNMENT.NEUTRAL

func _ready() -> void:
	element_type = Element2D.CellType.ACTOR
	element_id = 0 # Unique identifier for an actor

	# Set health
	health = max_health # Initial health

func _increase_health(amount: int) -> void:
	health += amount

func _add_to_inventory(item):
	if item is Gold:
		gold += item.amount
		print("Gold added: ", item.amount, " Total gold: ", gold)
	else:
		inventory.append(item)

func _remove_from_inventory(index: int) -> void:
	inventory.remove_at(index)

func _on_use_item(index: int) -> void:
	var item = inventory.get(index)
	if item:
		print("Using item: ", item.name)
		# Implement item use logic here, e.g., apply effects
		var used: bool = item._use()
		var equip_index = ""
		print("element_id")
		print(item.element_id)
		match item.element_id:
			Element2D.ItemType.SWORD:
				equip_index = "right_arm"

		print("equip_index")
		print(equip_index)
		if equip_index != "":
			# Unequip whatever is equipped
			print("Checking equipment: ", equipment[equip_index])
			if equipment[equip_index]:
				print("Unequipping previous item from: ", equip_index)
				_add_to_inventory(equipment[equip_index])
			equipment[equip_index] = item
			_update_armor()

		# If the item was used (like a potion), remove it from inventory
		# If it was equipped, it stays in inventory
		if used:
			print("Item used and removed from inventory: ", item.name)
			_remove_from_inventory(index)
			if not equip_index:
				item.queue_free() # Remove item from the game
		else:
			print("Item not used, remains in inventory: ", item.name)
	else:
		print("No item found at index: ", index)

func _on_unequipped_item(equip_index: String) -> void:
	if equipment.has(equip_index) and equipment[equip_index]:
		print("Unequipping item from: ", equip_index)
		_add_to_inventory(equipment[equip_index])
		equipment[equip_index] = null
	else:
		print("No item equipped in: ", equip_index)

func _update_armor() -> void:
	# Recalculate armor based on equipped items
	armor = 0
	for part in equipment.values():
		if part and part.has("armor"):
			armor += part.armor
	print("Updated armor: ", armor)

func _deal_damage() -> int:
	# Calculate damage based on strength and equipped weapon
	var base_damage = 1 + (strength / 2) # Base damage influenced by strength
	var weapon_damage = 0
	if equipment["right_arm"]:
		# Assuming the weapon has a damage property
		weapon_damage = equipment["right_arm"].damage
	var total_damage = base_damage + weapon_damage
	print("Dealing damage: ", total_damage)
	return total_damage

func _attack(target: Actor2D) -> int:
	var damage = _deal_damage()
	print("Attacking ", target.name, " for ", damage, " damage.")
	# Calculate damage dealt after armor reduction
	var effective_damage = target._get_attack(damage)
	return effective_damage

func _get_attack(damage_dealt: int) -> int:
	# Reduce damage by armor, ensuring at least 1 damage is taken
	var effective_damage = max(damage_dealt - armor, 0)
	print(name, " takes ", effective_damage, " damage after armor reduction.")
	health -= effective_damage
	print(name, " health is now ", health, "/", max_health)
	# Counter attack
	return effective_damage

func _die() -> void:
	print(name, " has died.")
	# Additional logic for when the actor dies (e.g., play animation, drop loot)
	queue_free() # Remove the actor from the game
