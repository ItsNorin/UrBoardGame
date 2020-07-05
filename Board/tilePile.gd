extends "res://Board/baseTile.gd"

class_name PileTile

const PieceTypes = [
	preload("res://Pieces/blue_piece.tscn"),
	preload("res://Pieces/yellow_piece.tscn")
]

# Type of piece
export var pieceType:int = 0

# Number of pieces in pile
export var pieceCountStart:int = 0

# How far pieces will spread in pixels
export var spread:float = 30

# Position of middle of pile
export var xOffset:int = 64
export var yOffset:int = 64

# Actual pile of pieces
var pile = []
var rng = RandomNumberGenerator.new()

var pileRotation:float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	pileRotation = rng.randf_range(0,2*PI)
	addPieces(pieceCountStart)
	pass

# Evenly distribute all pieces
func spreadPieces():
	var n:int = pieceCount()
	var phi:float = (sqrt(5)+1)/2
	var alpha = 2
	var borderPoints:float = alpha*sqrt(pieceCount())
	for i in range(n):
		var theta:float = pileRotation + ((2*PI*i) / (phi*phi))
		var radius:float = spread
		if i < n - borderPoints:
			radius *= sqrt(i+.5)/sqrt(n-(borderPoints+1)/2)
		var piece:Piece = pile[i]
		piece.position = Vector2(xOffset + radius*cos(theta), yOffset + radius*sin(theta))
	pass

# Adds a new piece to top of pile
func addPiece(p:Piece):
	# create new piece at given position
	p.set_rotation(rng.randf_range(0, 2*PI)) # rotate piece randomly
	pile.push_front(p)
	add_child(p)
	spreadPieces()
	pass
	
# Add "count" pieces to pile
func addPieces(count:= 1):
	for _n in range(count):
		addPiece(PieceTypes[pieceType].instance())
	pass

func removePiece() -> Piece:
	var p = pile.front()
	pile.pop_front()
	remove_child(p)
	spreadPieces()
	return p

# Remove "count" pieces, returns array of removed pieces
func removePieces(count:= 1):
	var piecesRemoved = []
	for _n in count:
		piecesRemoved.insert(removePiece())
	return piecesRemoved

# Number of pieces in pile
func pieceCount():
	return pile.size();
	
func getPiece() -> Piece:
	if pieceCount() <= 0:
		return null
	return pile[0]
	
func canAccept(p:Piece) -> bool:
	if p == null:
		return false
	return PieceTypes[pieceType].instance().color == p.color
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#var delay = 0
#func _process(delta):
#	delay += delta
#	if delay > 2:
#		addPiece()
#		delay = 0
#	pass
