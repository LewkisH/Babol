extends Node

var player_clamp_normal = [Vector2(426, 900), Vector2(856, 900)]
var player_clamp_bossfight = [Vector2(226, 900), Vector2(1056, 900)]
var player_clamp_rect = player_clamp_normal
var boss_fight_started = false
const MAX_BREATH = 200
func _on_bossfight_started():
	print("boss fight started")
	boss_fight_started = true
	
	player_clamp_rect = player_clamp_bossfight
func _on_bossfight_ended(did_win):
	boss_fight_started = false
	print("boss fight ended")
	if did_win:
		get_tree().change_scene_to_file("res://scenes/cutscene_end.tscn")
	player_clamp_rect = player_clamp_normal

func _reset_game():
	boss_fight_started = false
	player_clamp_rect = player_clamp_normal
