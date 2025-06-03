class_name PlayerLight extends CharacterBody2D

signal bubble_release(bubble_scene, location, mouse_location)
signal bubble_blow(hold_value)
signal bubble_inhale(hold_value)
signal no_air()
signal killed

@export var speed = 300
@export var rate_of_fire := 0.1
@export var breath := Globals.MAX_BREATH
@export var rate_of_blow := 0.03
@export var rotation_offset: float = deg_to_rad(90.0)  # Offset in radians (e.g., PI/2, PI)
@onready var muzzle = $Muzzle
@onready var animations = $Sprite2D
@onready var inflate_sound = $SFX/Inflate
@onready var empty_sound = $SFX/Empty
@onready var inhale_sound = $SFX/Inhale
@export var max_hold_time: float = 0  # Maximum time you can hold

var bubble_scene = preload("res://scenes/bubble.tscn")
var bubble_grow_rate = 1
var breath_loss_rate = 0.001
var shoot_cd := false
var bubble_cd := false

func _process(_delta):
	if Input.is_action_just_pressed("shoot") && !Input.is_action_pressed("inhale"):
		if !bubble_cd && breath > 0:
			bubble_cd = true
			while Input.is_action_pressed("shoot"):
				blow()
				await get_tree().create_timer(rate_of_blow).timeout
			bubble_cd = false
		elif breath < 1: 
			empty_sound.play()
			no_air.emit()
			
	elif Input.is_action_just_released("shoot"):
		
		if !shoot_cd:
			inflate_sound.stop()
			shoot_cd = true
			shoot()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

	if Input.is_action_just_pressed("inhale") && !Input.is_action_pressed("shoot"):
		if !bubble_cd && breath < Globals.MAX_BREATH:
			bubble_cd = true
			while Input.is_action_pressed("inhale") && breath < Globals.MAX_BREATH:
				inhale()
				await get_tree().create_timer(rate_of_blow).timeout
			inhale_sound.stop()
			bubble_cd = false
		else:
			inhale_sound.stop()
	elif Input.is_action_just_released("inhale"):
		inhale_sound.stop()

func _physics_process(_delta):
	var direction = Vector2(Input.get_axis("move_left", "move_right"), 0)

	velocity = direction * speed
	if direction.x > 0:
		animations.play("right")
	elif direction.x < 0:
		animations.play("left")
	else:
		animations.play("idle")
	move_and_slide()
	var mouse_position = get_global_mouse_position()
	var angle_to_mouse = (mouse_position - global_position).angle()
	rotation = angle_to_mouse + rotation_offset
	$RotationPoint.look_at(get_local_mouse_position())
	
	global_position = global_position.clamp(Globals.player_clamp_rect[0], Globals.player_clamp_rect[1])

func shoot():
	bubble_release.emit(bubble_scene, muzzle.global_position, get_global_mouse_position())

func blow():
	if !inflate_sound.is_playing():
		inflate_sound.play()

	bubble_blow.emit()

func inhale():
	if !inhale_sound.is_playing():
		inhale_sound.play()
	bubble_inhale.emit()

func die():
	killed.emit()
	queue_free()
