extends Node

export (int) var tileSize

enum TILE_TYPE { EMPTY = 0, BASE, ROSETTE, L_PILE, R_PILE, L_GOAL, R_GOAL }

const Tiles = [
	null,
	preload("res://Board/baseTile.tscn"),
	preload("res://Board/rosette.tscn"),
	preload("res://Board/tilePile.tscn")
]

var diceRoller:DiceRoller

# positions for dice roller on left/right side of screen
var diceRollerPosLeft:Vector2 = Vector2(-96, 160)
var diceRollerPosRight:Vector2 = Vector2(378, 160)

# all tiles on board except for starting and ending piles
var leftStart = []
var rightStart = []
var center = []
var leftSafe = []
var rightSafe = []

var clickBox:RectangleShape2D

# false: left's turn
# true:  right's turn
var currentTurn:bool = true
var rollReady:bool = false
var currentRoll:int = 0

var currentMoves = []

func _ready():
	randomize()
	buildBoard()
	
	diceRoller = get_node("DiceRoller")
	diceRoller.connect("rolls_done", self, "_on_dice_roll_ready")
	initDice()
	
	pass
	
# When dice roll is ready,
func _on_dice_roll_ready(score:int):
	print("rolled: " + String(score))
	# Find all tiles with current player pieces, highlight them
	currentMoves = getValidTiles(score)
	setTileHighlight(currentMoves, true)
	currentRoll = score
	rollReady = true
	pass

func _on_tile_clicked(tile:BaseTile):
	print(Vector2(tile.xPos,tile.yPos))
	var swapTurns = false
	var madeValidMove = false
	# if roll is ready 
	if rollReady:
		# if player cannot move, swap turns
		if currentRoll == 0 || currentMoves.size() == 0:
			swapTurns = true
			madeValidMove = true
		# if clicked tile has current player's piece
		if tile.getState() == getCurrentColor():
			if canMove(tile.xPos, tile.yPos, currentRoll):
				var type = movePiece(tile.xPos, tile.yPos, currentRoll)
				swapTurns = true
				madeValidMove = true
				# don't swap turns if landing on a rosette
				if type == TILE_TYPE.ROSETTE:
					swapTurns = false
				
	if swapTurns:
		currentTurn = !currentTurn
			
	if madeValidMove:
		initDice()
		# end of turn board cleanup
		setTileHighlight(currentMoves, false)
		currentMoves.clear()
	pass
	
# Called every frame. 'delta' is the elapsed time in seconds since the previous frame.
#func _process(delta):
	#testMoves(round(rand_range(0,1))*2, delta)
	#pass

func initDice():
	rollReady = false
	if currentTurn:
		diceRoller.position = diceRollerPosRight
	else:
		diceRoller.position = diceRollerPosLeft
	diceRoller.waitForClick()
	pass

# get all tiles that can move given distance for current player
func getValidTiles(moveDistance:int):
	var validTiles = []
	if moveDistance == 0:
		return validTiles
		
	var t:BaseTile
	if currentTurn:
		t = rightStart[0]
	else:
		t = leftStart[0]
	
	while t != null:
		if t.getState() == getCurrentColor(): 
			if canMove(t.xPos, t.yPos, moveDistance):
				validTiles.push_back(t)
		t = getNextTile(t, getCurrentColor())
	
	return validTiles
	
func setTileHighlight(tiles, highlight:bool):
	for t in tiles:
		(t as BaseTile).setHighlight(highlight)
	pass

func getCurrentColor() -> String:
	if currentTurn:
		return "yellow"
	return "blue"

# moves piece to new position, returns captured piece to starting pile
# returns type of tile piece has landed on, 0 if empty
# DOES NOT CHECK IF MOVE IS VALID, USE 'canMove' FIRST!
func movePiece(x:int, y:int, distance:int):
	var tileA:BaseTile = getTile(x, y)
	var tileB:BaseTile = getTileDisplaced(x, y, distance)
	
	# prepare to swap pieces
	var piece = tileA.getPiece()
	var pieceB = null
	# move piece to new tile
	piece = tileA.removePiece()
	if tileType(tileB.xPos, tileB.yPos) != TILE_TYPE.L_GOAL && tileType(tileB.xPos, tileB.yPos) != TILE_TYPE.R_GOAL:
		pieceB = tileB.removePiece()
# warning-ignore:return_value_discarded
	tileB.addPiece(piece)
	capturePiece(pieceB)
	return tileType(tileB.xPos, tileB.yPos)

func capturePiece(piece:Piece):
	if piece == null:
		return
	match piece.color:
		"blue":
			leftStart[0].addPiece(piece)
		"yellow":
			rightStart[0].addPiece(piece)
	pass


# true if any of given tiles have moves for given distance
func hasMoves(tiles, dist:int) -> bool:
	for i in tiles:
		var t:BaseTile = i as BaseTile
		if canMove(t.xPos, t.yPos, dist):
			return true
	return false	
	
	
# True if piece can move to given tile
func canMove(x:int, y:int, dist:int) -> bool:
	var tile = getTile(x, y)
	var newTile:BaseTile = getTileDisplaced(x, y, dist)
	if newTile == null:
		return false
	return newTile.canAccept(tile.getPiece())
	
# get a tile "distance" tiles forward from given x/y position on board
# returns null if cannot find given tile, or tile does not have a color state
func getTileDisplaced(x:int, y:int, distance:int) -> BaseTile:
	var tile:BaseTile = getTile(x,y)
	if tile == null || tile.getState() == null:
		return null
	
	var color = tile.getState()
	for _i in range(distance):
		tile = getNextTile(tile, color)
		
	return tile

# finds next tile following given one, color needed for end of center where paths split
func getNextTile(tile:BaseTile, color:String) -> BaseTile:
	if tile == null:
		return null
	
	var tileNext
	if tile.xPos == 1 && tile.yPos == 0:
		tileNext = leftSafe[0]
		if color == "yellow":
			tileNext = rightSafe[0]
	else:
		tileNext = tile.nextTile
		
	return tileNext
	
# converts x and y to specific tile on board
func getTile(x:int, y:int) -> BaseTile:
	if y >= 0 && y <= 7:
		match x:
			0:
				if y <= 2:
					return leftSafe[y]
				if y >= 3:
					return leftStart[y-3]
			1:
				return center[y]
			2:
				if y <= 2:
					return rightSafe[y]
				if y >= 3:
					return rightStart[y-3]
	return null

# Assemble board, link most tiles
func buildBoard():
	for y in range(8):
		center.push_back(createNewTile(1,y))
	for y in range(3):
		leftSafe.push_back(createNewTile(0,y))
		rightSafe.push_back(createNewTile(2,y))
	for y in range(5):
		leftStart.push_back(createNewTile(0,y+3))
		rightStart.push_back(createNewTile(2,y+3))
	
	# make each piece on board link to the next
	# excludes top center, as it splits
	for i in range(4):
		leftStart[i].nextTile = leftStart[i+1]
		rightStart[i].nextTile = rightStart[i+1]
	for i in range(7):
		center[i+1].nextTile = center[i]
	for i in range(2):
		leftSafe[i].nextTile = leftSafe[i+1]
		rightSafe[i].nextTile = rightSafe[i+1]
	leftStart.back().nextTile = center.back()
	rightStart.back().nextTile = center.back()
	pass

# create a new properly configured tile at given board position
func createNewTile(x:int, y:int):
	var type = tileType(x,y)
	var currentTile:BaseTile
	
	currentTile = Tiles[min(type, TILE_TYPE.ROSETTE+1)].instance()
	currentTile.xPos = x
	currentTile.yPos = y
	currentTile.position = Vector2(x*tileSize, y*tileSize)
	add_child(currentTile)
	
	if type == TILE_TYPE.L_PILE || type == TILE_TYPE.L_GOAL:
		(currentTile as PileTile).pieceType = 0
	elif type == TILE_TYPE.R_PILE || type == TILE_TYPE.R_GOAL:
		(currentTile as PileTile).pieceType = 1

	if type == TILE_TYPE.L_PILE || type == TILE_TYPE.R_PILE:
		(currentTile as PileTile).addPieces(7)
	
	currentTile.connect("tile_clicked", self, "_on_tile_clicked")
	
	return currentTile

# Type of tile at given a x and y position on board
func tileType(x:int, y:int):
	if x >= 0 && x <= 2 && y >= 0 && y <= 7:
		if (y == 1 || y == 7) && (x == 0 || x == 2) || x == 1 && y == 4:
			return TILE_TYPE.ROSETTE
		elif y == 2:
			if x == 0:
				return TILE_TYPE.L_GOAL
			if x == 2:
				return TILE_TYPE.R_GOAL
		elif y == 3:
			if x == 0:
				return TILE_TYPE.L_PILE
			if x == 2:
				return TILE_TYPE.R_PILE
		return TILE_TYPE.BASE
	return TILE_TYPE.EMPTY

