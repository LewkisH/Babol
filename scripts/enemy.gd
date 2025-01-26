class_name Enemy extends Area2D

signal killed(points)
signal hit

@onready var _animated_sprite = $Sprite
@export var speed = 150
@export var points = 100
@export var hp = 1
var amplitude = 2  # Amplitude of the sine wave
var frequency = 2.0  # Frequency of the sine wave
var time = 0.0  # Time tracker
var max_hp = 1

func _ready():
	max_hp = hp
	print(max_hp, " MAX HP")

func _physics_process(delta):
	time += delta
	global_position.y += speed * delta
	global_position.x += amplitude * sin(frequency * time)
	_animated_sprite.play("fly")

func die():
	queue_free()	

func _on_body_entered(body):
	if body is Player:
		body.die()
		die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func take_damage(amount, disappear, bubble):
	print("taking dam", amount, hp)
	hp -= amount
	if hp <= 0:
		killed.emit(max_hp* 100, global_position)
		print("KILLED, got pints:", max_hp* 100)
		if !disappear:
			# attach mosquito sprite to bubble
			var enemy_sprite = (self.get_child(0).duplicate())
			enemy_sprite.scale = self.scale / bubble.scale
			enemy_sprite.rotation = -bubble.rotation
			enemy_sprite.z_index = -20
			bubble.add_child(enemy_sprite)
		die()
	else:
		hit.emit()
