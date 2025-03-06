extends AnimatedSprite2D
class_name Stim

@export var StimType : StimResource

func getType() -> int:
	return StimType.type
func getDecayCost() -> int:
	return StimType.decayAmount
