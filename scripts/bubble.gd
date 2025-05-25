extends Area2D

@export var speed = 1.5
@export var damage = 1
@export var direction = 0.0
@export var curve = deg_to_rad(0.5)
@export var hold_time = 0.0

func _ready():
	speed = max(speed - float(hold_time)/50 , 0.3)
	curve = deg_to_rad([-0.5, 0.5].pick_random())
	damage = round(damage+round(hold_time/25)**2) # 1 / 2 / 25 / 10
	#damage = 100 
	scale = Vector2(1+hold_time/25, 1+hold_time/25)
	

func _physics_process(delta):
	
	# Rotate the direction vector by the random angle
	direction = direction.rotated(curve)

	global_position += -direction * delta * speed
	rotation = direction.angle() + deg_to_rad(90.0)

func _on_visible_on_screen_notifier_2d_screen_exited():
	call_deferred("queue_free")

func _on_area_entered(area):
	print("REMAINING BUBBLE DAM: ", damage)
	if area is Enemy || area is Boss:
		# Defer the entire collision handling
		call_deferred("_handle_collision", area)

# New method to handle collisions after physics step
func _handle_collision(area):
	if area is Enemy || area is Boss:
		if area.hp < damage:
			damage -= area.hp
			area.take_damage(damage, false, self)
		else:
			area.take_damage(damage, true, self)
			queue_free()
