extends Control

# Dialogue data: character names, dialogue lines, and optional images
var dialogue = [
	{"name": "Narrator", "text": "One day, a boy was chilling in the park by a pond.", "background": "res://assets/textures/cutscene_1/park1.png"},
	{"name": "Narrator", "text": "But everything changed when the mosquitos attaccked.", "background": "res://assets/textures/cutscene_1/park2.png"},
	{"name": "Narrator", "text": "They kept biting and biting and he had had enough.", "background": "res://assets/textures/cutscene_1/park3.png"},
	{"name": "Narrator", "text": "He summoned a bubble, and the mosquitos got caught inside of it!", "background": "res://assets/textures/cutscene_1/park4.png"},
	{"name": "Bob-Bill", "text": "It's time to put an end to their reign!", "background": "res://assets/textures/cutscene_1/park4.png"},
	{"name": "Narrator", "text": "So he took his crown and cape, and flew into the forest.", "background": "res://assets/textures/cutscene_1/park5.png"},
]

var current_index = 0  # Keep track of the current dialogue line

# References to UI elements
@onready var name_label = $TextureRect/NameLabel
@onready var text_label = $TextureRect/TextLabel
@onready var background = $Background

var cutscene_active = false

func _ready():
	# Initialize the first dialogue line
	show_dialogue(current_index)

func show_dialogue(index):
	if index >= dialogue.size():
		end_cutscene()  # End the cutscene if we've reached the end
		return

	var line = dialogue[index]
	name_label.text = line["name"]
	text_label.text = line["text"]
	
	# Update the background if specified
	if line.has("background"):
		background.texture = load(line["background"])

func _on_NextButton_pressed():
	current_index += 1
	show_dialogue(current_index)

func end_cutscene():
	# Add your logic to exit the cutscene (e.g., go back to the game scene)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	#queue_free()

func _input(event):
	# If a cutscene is active, only allow advancing the dialogue with the Enter key
	if Input.is_action_just_pressed("shoot"):
		_on_NextButton_pressed()  # Call the method to advance dialogue

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		Globals._on_bossfight_ended(false)
		get_tree().reload_current_scene()
