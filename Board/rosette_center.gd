extends "res://Board/baseTile.gd"

func canAccept(p:Piece) -> bool:
	if p == null:
		return false
	return self.piece == null

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	pass # Replace with function body.
