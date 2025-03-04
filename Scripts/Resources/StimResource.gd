extends Resource

# Instead of making many item scenes, we make a resource and implement the logic in the player script.
class_name StimResource

enum TYPE {
	HEAL,
	DASH,
	DOUBLE_JUMP,
	FLOAT,
	MAGNETIC
}

@export var type : TYPE
@export var decayAmount : int
