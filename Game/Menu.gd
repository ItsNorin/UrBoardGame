extends Control

signal start_two_player

func _on_TwoPlayerButton_pressed():
	self.hide()
	emit_signal("start_two_player")
	pass # Replace with function body.

func _play_button_plip():
	get_node("ButtonPlip").play(0.0)
	pass
