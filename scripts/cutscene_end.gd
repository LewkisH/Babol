extends Control

# Dialogue data: character names, dialogue lines, and optional images
var dialogue = [
	{"name": "Narrator", "text": "THIS IS THE FINAL SHOWDOWN!", "background": "res://assets/textures/cutscene_end/final1.png"},
	{"name": "Bob-Bill", "text": "Your tyranny ends here, Mosquito Queen!", "background": "res://assets/textures/cutscene_end/final2.png"},
	{"name": "Narrator", "text": "With one final blow, Bob-Bill vanquished the Mosquito Queen. The forest was free once more.", "background": "res://assets/textures/cutscene_end/final3.png"}
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
