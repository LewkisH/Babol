extends CharacterBody2D

var speed = 400
var player_pos
var target_pos

@onready var player = get_node("../Player")

func _physics_process(delta: float) -> void:
	player_pos = player.position
	target_pos = (player.position - position).normalized()
	
	if position.distance_to(player_pos) > 3:
		position += target_pos * speed * delta
