class_name Boss extends Area2D

signal killed(points)
signal hit

@onready var _animated_sprite = $SpriteSheet
@onready var timer = $Timer
@onready var health_bar = $Node2D/ProgressBar
@onready var death_sound = $SFX/Death
@onready var buzzing_sound = $SFX/Buzzing
@onready var hurt_sound = $SFX/Hurt

@export var speed = 150
@export var points = 300
@export var hp = 100
var amplitude = 70  # Amplitude of the sine wave while dodging
var frequency = 1.0  # Frequency of the sine wave
var time = 0.0  # Time tracker
var charging = true
var charge_speed = 4.0


enum State {
	INTRO,
	DODGE,
	ATTACK,
	DEATH
}

var current_state = State.INTRO

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp

func _physics_process(delta):

	time += delta
	match current_state:
		State.INTRO:
			global_position.y = min(global_position.y + speed * delta, get_viewport_rect().size.y * 0.33)
			global_position.x = lerp(global_position.x, get_viewport_rect().size.x * 0.5, 0.01)
			_animated_sprite.play("fly")
			print(global_position.x - get_viewport_rect().size.x * 0.5)
			if abs(global_position.x - get_viewport_rect().size.x / 2) < 10:
				current_state = State.DODGE
				print("im finna doge")

		State.DODGE:
			global_position.y += sin(time * 2) * speed * delta * 0.2
			global_position.x = lerp(global_position.x, 640 + amplitude * sin(frequency * time) * PI, 0.05)
			_animated_sprite.play("fly")
			if timer.is_stopped():
				timer.wait_time = randf_range(5.0, 10.0)
				timer.start()

		State.ATTACK:
			var target_y = get_viewport_rect().size.y
			if global_position.y < target_y && charging:
				_animated_sprite.play("charge")
				global_position.y += speed * charge_speed * delta
				global_position.x += (position.x - global_position.x) * 0.05
				
			else:
				charging = false
				global_position.x = lerp(global_position.x, get_viewport_rect().size.x * 0.5, 0.05)
				global_position.y = lerp(global_position.y, get_viewport_rect().size.y * 0.33, 0.05)
				if (global_position - Vector2(get_viewport_rect().size.x * 0.5, get_viewport_rect().size.y * 0.33)).length() < 10:
					current_state = State.DODGE


func _on_timer_timeout() -> void:
	print("ATTACKING")
	charge_speed += 0.5
	current_state = State.ATTACK
	charging = true
	timer.stop()



func die():
	Globals._on_bossfight_ended(true)
	queue_free()	

func _on_body_entered(body):
	print(body)
	if body is Player:
		body.die()
		await get_tree().create_timer(1.5).timeout
		die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func take_damage(amount, disappear, bubble):
	print("taking dam", amount, hp)
	hp -= amount
	hurt_sound.play()
	health_bar.value = hp
	if hp <= 0:
		death_sound.play()
		killed.emit(points)
		if !disappear:
			#bubble takes mosquito with it
			var enemy_sprite = (self.get_child(0).duplicate())
			enemy_sprite.scale = self.scale / bubble.scale
			enemy_sprite.rotation = -bubble.rotation
			enemy_sprite.z_index = -20
			bubble.add_child(enemy_sprite)
		die()
		

		

	else:
		hit.emit()
