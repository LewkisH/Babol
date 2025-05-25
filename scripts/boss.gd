class_name Boss extends Area2D

signal killed(points)
signal hit

@onready var _animated_sprite = $SpriteSheet
@onready var timer = $Timer
@onready var health_bar = $Node2D/ProgressBar
@onready var death_sound = $SFX/Death
@onready var buzzing_sound = $SFX/Buzzing
@onready var hurt_sound = $SFX/Hurt
@onready var path2d = get_node("../..")
@onready var path_follow = get_parent() # Assuming the boss is a child of PathFollow2D

#paths
@export var intro_curve: Curve2D
@export var dodge_curve: Curve2D
@export var attack_curve: Curve2D

#stats
@export var speed = 150
@export var points = 300
@export var hp = 100
var amplitude = 70  # Amplitude of the sine wave while dodging
var frequency = 1.0  # Frequency of the sine wave
var time = 0.0  # Time tracker
var charging = true
var charge_speed = 4.0

# Path tracking
var path_progress = 0.0
var path_speed = 0.5
var path_completed = false

enum State {
	INTRO,
	DODGE,
	ATTACK,
	DEATH
}

var current_state = State.INTRO

func _ready():
	print(path2d)
	health_bar.max_value = hp
	health_bar.value = hp
	# Start timer for intro state
	timer.wait_time = 3.0
	timer.start()

func _physics_process(delta):

	time += delta
	
	match current_state:
		State.INTRO:
			path2d.curve = intro_curve
			
			 # Handle path following
			if !path_completed:
				path_progress += path_speed * delta
				if path_progress >= 1.0:
					path_progress = 1.0
					path_completed = true
				
				path_follow.progress_ratio = path_progress
			
			_animated_sprite.play("fly")
			
		State.DODGE:
			path2d.curve = dodge_curve
			
			# Handle path following for dodge state
			if !path_completed:
				path_progress += path_speed * delta
				if path_progress >= 1.0:
					path_progress = 1.0
					path_completed = true
					# When dodge path is completed, start timer for attack
					if timer.is_stopped():
						timer.wait_time = randf_range(5.0, 10.0)
						timer.start()
				
				path_follow.progress_ratio = path_progress
			
			_animated_sprite.play("fly")
				
		State.ATTACK:
			print("atak")
			
			# Reset path tracking for attack state
			path_progress = 0.0
			path_completed = false
			path2d.curve = attack_curve	
			
			_animated_sprite.play("charge")
				#global_position.y += speed * charge_speed * delta
				#global_position.x += (position.x - global_position.x) * 0.05
				#
			#else:
				#charging = false
				#global_position.x = lerp(global_position.x, get_viewport_rect().size.x * 0.5, 0.05)
				#global_position.y = lerp(global_position.y, get_viewport_rect().size.y * 0.33, 0.05)
				#if (global_position - Vector2(get_viewport_rect().size.x * 0.5, get_viewport_rect().size.y * 0.33)).length() < 10:
					#current_state = State.DODGE


func transition_to_state(new_state):
	# Get the current position of the boss
	var current_position = global_position
	
	# Change state
	current_state = new_state
	
	# Setup path based on new state
	var new_curve = null
	match new_state:
		State.DODGE:
			new_curve = dodge_curve.duplicate()
		State.ATTACK:
			new_curve = attack_curve.duplicate()
	
	if new_curve and new_curve.get_point_count() > 0:
		# Modify the first point of the new curve to match current position
		new_curve.set_point_position(0, current_position)
		path2d.curve = new_curve
	
	# Reset path tracking
	path_progress = 0.0
	path_completed = false

func _on_timer_timeout() -> void:
	if current_state == State.INTRO:
		transition_to_state(State.DODGE)
		timer.stop()
	else:  
		charge_speed += 0.5
		transition_to_state(State.ATTACK)
		charging = true
		timer.stop()

func die():
	Globals._on_bossfight_ended(true)
	queue_free()	

func _on_body_entered(body):
	if body is Player:
		body.die()
		await get_tree().create_timer(1.5).timeout
		die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func take_damage(amount, disappear, bubble):
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
