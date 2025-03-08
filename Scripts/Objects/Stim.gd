extends Sprite2D
class_name Stim

@export var stimType : StimResource
var used : bool = false
func isUsed() -> bool:
	return used
func setType(newType : StimResource) -> void:
	stimType = newType
func getType() -> int:
	return stimType.type
func getDecayCost() -> int:
	return stimType.decayAmount
