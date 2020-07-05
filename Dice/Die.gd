extends TextureRect

class_name Die

export (float) var timeBetweenFrames = .05
export (int) var numberOfFrames = 15

signal rolling_done

const FramesScoring = [
	preload("res://Dice/pips_a_scoring.svg"),
	preload("res://Dice/pips_b_scoring.svg")
]

const FramesNotScoring = [
	preload("res://Dice/pips_a_not_scoring.svg"),
	preload("res://Dice/pips_b_not_scoring.svg")
]

var scoring:bool

export var rolling:bool
var lastRollTime:float
var timesRolled:int

var rng = RandomNumberGenerator.new()

func setRandomRoll():
	# always 50/50 chance of die scoring
	scoring = rng.randi_range(0,1)
	# display textures
	if scoring:
		self.texture = FramesScoring[rng.randi_range(0,1)]
	else:
		self.texture = FramesNotScoring[rng.randi_range(0,1)]
	self.flip_h = rng.randi_range(0,1)
	return scoring

func roll():
	rolling = true;
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	setRandomRoll()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rolling:
		if timesRolled <= numberOfFrames:
			lastRollTime += delta
			if lastRollTime >= timeBetweenFrames:
				timesRolled += 1
				lastRollTime = 0
				setRandomRoll()
		else:
			rolling = false
			lastRollTime = 0
			timesRolled = 0
			emit_signal("rolling_done", scoring)
	pass
