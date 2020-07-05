extends Node2D

class_name Piece

export (String) var color; 

var tween:Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = get_node("Tween")
	pass # Replace with function body.

func moveTo(pos:Vector2):
# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "position", 
		self.position, pos, 1, 
		Tween.TRANS_CIRC, Tween.EASE_OUT)
# warning-ignore:return_value_discarded
	tween.start()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
