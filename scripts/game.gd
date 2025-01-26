extends Node2D


@export var enemy_scenes: Array[PackedScene] = []

@onready var player_spawn_pos = $PlayerSpawnPos
@onready var bubble_container = $BubbleContainer
@onready var timer = $EnemySpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var hud = $UILayer/HUD
@onready var gos = $UILayer/GameOverScreen
@onready var pb = $ParallaxBackground

@onready var bubble_sound = $SFX/BubbleSound
@onready var hit_sound = $SFX/HitSound
@onready var explode_sound = $SFX/ExplodeSound
@onready var mosquito_death_sound = $SFX/MosquitoDeath

@onready var bubble_preview = $UILayer/HUD/BigBubble
@onready var bubble_particles = $UILayer/HUD/BubbleParticles
@onready var hud_no_air = $UILayer/HUD/NoAir

const BREATH_RATE = 2
const MAX_BREATH = Globals.MAX_BREATH
var exhale_time = 0
var difficulty_multiplier = 0.005

var player = null
var score := 0:
	set(value):
		score = value
		hud.score = score

var breath := 200:
	set(value):
		breath = value
		hud.breath = breath
		player.breath = breath

var high_score

var scroll_speed = 100

func _ready():
	bubble_preview.visible = false
	bubble_particles.visible = false
	
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file!=null:
		high_score = save_file.get_32()
	else:
		high_score = 0
		save_game()
	
	score = 0
	hud.get_child(1).max_value = MAX_BREATH # set max value of breath hud bar
	print(hud.get_child(1))
	player = get_tree().get_first_node_in_group("player")
	assert(player!=null)
	player.global_position = player_spawn_pos.global_position
	player.bubble_release.connect(_on_player_bubble_release)
	player.bubble_blow.connect(_on_player_bubble_blow)
	player.bubble_inhale.connect(_on_player_bubble_inhale)
	hud.make_it_harder.connect(_on_make_it_harder)
	player.killed.connect(_on_player_killed)
	player.no_air.connect(_on_no_air)

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		# get_tree().quit()
		get_tree().change_scene_to_file("res://scenes/cutscene_1.tscn")

	elif Input.is_action_just_pressed("reset"):
		Globals._on_bossfight_ended(false)
		get_tree().reload_current_scene()

	if Input.is_action_pressed("shoot") && exhale_time>0:
		bubble_preview.visible = true
		bubble_particles.visible = true
	else:
		bubble_preview.visible = false
		bubble_particles.visible = false
		bubble_preview.frame = 0
		bubble_particles.frame = 0
	
	if timer.wait_time > 0.5:
		timer.wait_time -= delta*difficulty_multiplier
	elif timer.wait_time < 0.5:
		timer.wait_time = 0.5
	
	pb.scroll_offset.y += delta*scroll_speed
	if pb.scroll_offset.y >= 960:
		pb.scroll_offset.y = 0

	



func _on_enemy_spawn_timer_timeout():
	var e
	if randi() % 3 < 2:
		e = enemy_scenes[1].instantiate()
	else:
		e = enemy_scenes.pick_random().instantiate()
	e.global_position = Vector2(randf_range(426, 856), -50)
	e.killed.connect(_on_enemy_killed)
	e.hit.connect(_on_enemy_hit)
	enemy_container.add_child(e)

func _on_enemy_killed(points, enemy_position):
	hit_sound.play()
	score += points
	mosquito_death_sound.global_position = enemy_position
	mosquito_death_sound.play()
	if score > high_score:
		high_score = score

func _on_enemy_hit():
	hit_sound.play()

func _on_player_killed():
	explode_sound.play()
	gos.set_score(score)
	gos.set_high_score(high_score)
	save_game()
	Globals._reset_game()
	gos.visible = true
	await get_tree().create_timer(1.5).timeout
	
	
func _on_player_bubble_release(bubble_scene, location, mouse_location):
	if exhale_time > 0: 
		
		var bubble = bubble_scene.instantiate()
		bubble.hold_time = exhale_time#change variables in bubble based on hold time
		bubble.global_position = location
		bubble.direction = location - mouse_location
		bubble_container.add_child(bubble)
		bubble_sound.pitch_scale = max(4 - bubble.scale.x, 0.3)
		exhale_time = 0
		bubble_sound.play()

func _on_player_bubble_blow():
	# print("bubble size: ", (exhale_time/25)+1)
	if breath > 0:
		bubble_preview.frame = exhale_time*0.04 # choose the frame from bubble growing spritesheet
		bubble_particles.play("default")
		exhale_time += BREATH_RATE
		breath -= BREATH_RATE


func _on_player_bubble_inhale():
	if breath < MAX_BREATH:
		breath += BREATH_RATE

func _on_make_it_harder(value):
	timer.wait_time -= 0.05
	print(Globals.boss_fight)
	if value == 3 && !Globals.boss_fight:
		var boss = load("res://scenes/boss.tscn").instantiate()
		enemy_container.add_child(boss)
		Globals._on_bossfight_started()
		
func _on_no_air():
	hud_no_air.visible = true
	await get_tree().create_timer(0.4).timeout
	hud_no_air.visible = false

func start_cutscene():
	
	hud.visible = false
	var cutscene_scene = load("res://scenes/control.tscn")
	var cutscene = cutscene_scene.instantiate()
	add_child(cutscene)
	
	# Connect the tree_exited signal to _on_cutscene_finished method
	cutscene.connect("tree_exited", Callable(self, "_on_cutscene_finished"))
	get_tree().paused = true
	# Pause game logic while the cutscene plays
	set_process(false)

func _on_cutscene_finished():
	# Resume the game
	set_process(true)
	hud.visible = true
	print("Cutscene finished, back to the game!")
