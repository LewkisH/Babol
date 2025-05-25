extends Control


@onready var score = $Score:
	set(value):
		score.text = "Score: " + str(value)

@onready var breath = $Breath:
	set(value):
		breath.value = value
