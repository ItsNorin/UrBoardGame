extends Node2D

class_name DiceRoller

signal rolls_done

var label:Label
var bounds:ColorRect

var score:int = 0
var rollDoneCount:int = 0
var acceptClick:bool = false

var rollingNoise:AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	label = get_node("Label")
	bounds = get_node("ColorRect")
	rollingNoise = get_node("rollingNoise")
	for d in self.get_children():
		if d is Die:
			d.connect("rolling_done", self, "_on_roll_done")
	waitForClick()
	pass

# true if score is ready
func isScoreReady() -> bool:
	return rollDoneCount >= 4

func waitForClick():
	label.text = "Roll"
	rollDoneCount = 0
	acceptClick = true
	pass
	
func rollAll():
	label.text = "Rolling"
	rollDoneCount = 0
	score = 0
	acceptClick = false
	for d in self.get_children():
		if d is Die:
			d.roll()
	rollingNoise.play()
	pass

func _on_roll_done(scoring:bool):
	rollDoneCount += 1
	if scoring:
		score += 1
	if isScoreReady():
		label.text = String(score)
		emit_signal("rolls_done", score)
		rollingNoise.stop()
	pass	

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if bounds.get_rect().has_point(get_local_mouse_position()):
			if acceptClick:
				rollAll()
			get_tree().set_input_as_handled()
	pass
