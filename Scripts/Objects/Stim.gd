extends AnimatedSprite2D

class_name Stim

@export var StimStype : StimResource


func _ready() -> void:
	self.frame = StimStype.type

func getType() -> int:
	return StimStype.type
func getDecayCost() -> int:
	return StimStype.decayAmount
