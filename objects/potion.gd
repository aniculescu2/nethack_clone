## Potion class that extends Element2D
class_name Potion
extends Element2D


enum PotionType {
	HEALTH,
	MANA,
	STRENGTH,
	SPEED,
	UNKNOWN
}
## Preset type of potion
@export var potion_type: PotionType = PotionType.UNKNOWN
## Amount of potion to be applied
@export var potion_amount: int = 0
## Duration of potion effect in rounds
@export var potion_duration: int = 0
## Effect description of the potion
@export var potion_effect: String
func _ready() -> void:
	print("Potion ready: Type: %s, Amount: %d, Duration: %d seconds" % [PotionType.find_key(potion_type), potion_amount, potion_duration])
	element_id = Element2D.ItemType.POTION
	element_type = Element2D.CellType.ITEM
	texture_path = "res://textures/potion.png"

func _use() -> bool:
	print("Using potion: Type: %s, Amount: %d, Duration: %d seconds" % [PotionType.find_key(potion_type), potion_amount, potion_duration])
	# Implement potion effect logic here
	match potion_type:
		PotionType.HEALTH:
			# Apply health effect
			print("Applying health effect: +%d" % potion_amount)
			GlobalSignals.increase_health.emit(potion_amount) # Emit signal to increase health
		PotionType.MANA:
			# Apply mana effect
			print("Applying mana effect: +%d" % potion_amount)
		PotionType.STRENGTH:
			# Apply strength effect
			print("Applying strength effect: +%d" % potion_amount)
		PotionType.SPEED:
			# Apply speed effect
			print("Applying speed effect: +%d" % potion_amount)
		PotionType.UNKNOWN:
			print("Unknown potion type, no effect applied")
	return true # Indicate that the potion was used up and should be removed
