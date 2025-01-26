extends Control

signal make_it_harder(tier)

@onready var score = $Score:
	set(value):
		score.text = "Score: " + str(value)
		if value >= 1000:
			make_it_harder.emit(value/1000)

@onready var breath = $Breath:
	set(value):
		breath.value = value
