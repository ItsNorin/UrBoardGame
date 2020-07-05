extends Node2D

class_name BaseTile

signal tile_clicked

export var pieceXOffset:int = 64
export var pieceYOffset:int = 64

var piece:Piece = null

# tile's position on board
var xPos:int
var yPos:int

var tileImage:TextureRect
var highlight:TextureRect

var nextTile:BaseTile = null


# Called when the node enters the scene tree for the first time.
func _ready():
	tileImage = self.get_node("TextureRect")
	highlight = self.get_node("highlight")
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if tileImage.get_rect().has_point(get_local_mouse_position()):
			tileClicked()
			get_tree().set_input_as_handled()
	pass
	
func setHighlight(active:bool):
	highlight.visible = active
	pass
	
func tileClicked():
	emit_signal("tile_clicked", self)
	pass
	
# null if empty, or piece color if occupied
func getState():
	if getPiece() != null:
		return getPiece().color
	return null
	
func canAccept(p:Piece) -> bool:
	return getState() != p.color
	
func getPiece() -> Piece:
	return piece

# add a piece to tile if possible, returns true if unoccupied
func addPiece(p:Piece) -> bool:
	if getState() == null:
		piece = p
		piece.position = Vector2(pieceXOffset, pieceYOffset)
		add_child(piece)
		return true
	return false

# remove a piece from tile, returns removed piece
func removePiece() -> Piece:
	if getState() == null:
		return null
	var p = piece
	remove_child(piece)
	self.piece = null
	return p

func getNextTile() -> BaseTile:
	return nextTile

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
