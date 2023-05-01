extends Node2D


var man: PackedScene = preload("res://drop_point.tscn")
var soul: PackedScene = preload("res://box.tscn")

var score = 0
var highscore = 0
var started_game = false
var orig_velocity = Vector2.ZERO

const SAVE_FILE_PATH = "user://savedata.save"

@onready var bar = $ProgressBar
@onready var timer = $ProgressBar/Timer


func _ready():
	$Car.crashed.connect(_on_car_crashed)
	save_highscore()
	load_highscore()
	

func _process(_delta):
	bar.value = 1 - timer.time_left / timer.wait_time
	
	if !$StartTimer.is_stopped():
		$EndScreen.hide()
		$StartTimer/Countdown.text = str(ceil($StartTimer.time_left))
	if $StartTimer.time_left == 0.0:
		$StartTimer/Countdown.hide()
	
	if !started_game:
		if $Car.velocity != orig_velocity:
			start_game()
			started_game = true
	

func _on_seconds_timer_timeout():
	$ProgressBar/TimeLeft.text = str(round(timer.time_left))
	

func spawn():
	var man_inst = man.instantiate()
	man_inst.position = Vector2(randf_range(35, 1110), randf_range(95, 605))
	man_inst.cured.connect(_on_man_cured)
	$DropPoints.add_child(man_inst)
	var soul_inst = soul.instantiate()
	soul_inst.position = Vector2(randf_range(35, 1110), randf_range(95, 605))
	soul_inst.add_to_group("souls")
	$Packages.add_child(soul_inst)
	

func _on_man_cured():
	score += 1
	$ProgressBar/ScoreNum.text = str(score)
	$EndScreen/Label.text = str(score)
	$ProgressBar/Timer.start($ProgressBar/Timer.time_left + 8)
	spawn()
	

func _on_start_timer_timeout():
	$ProgressBar/ColorRect.hide()
	$ProgressBar/Timer.start()
	$ProgressBar/SecondsTimer.start()
	spawn()
	

func _on_timer_timeout():
	$Car.alive = false
	$Car.get_child(3).play("die")
	$Car/Crash.play()
	await get_tree().create_timer(.8).timeout
	$Car.get_child(3).play("RESET")
	$Car.position = Vector2(430, 315)
	$Car.rotation_degrees = 15
	$Car.alive = true
	game_over()
	score = 0
	

func _on_car_crashed():
	screen_shake()
	$Car/Crash.play()
	game_over()
	score = 0
	

func game_over():
	$EndScreen.show()
	for i in get_child(1).get_children():
		i.queue_free()
	for i in get_child(2).get_children():
		i.queue_free()
	
	orig_velocity = $Car.velocity
	await get_tree().create_timer(5).timeout
	started_game = false
	
	update_scores(score, highscore)

func save_highscore():
	var save_data = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	save_data.store_var(highscore)
	save_data.close()
	

func load_highscore():
	var save_data
	if FileAccess.file_exists(SAVE_FILE_PATH):
		save_data = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		highscore = save_data.get_var()
		save_data.close()
		

func update_scores(new_score, _new_highscore):
	new_score += 1
	$ProgressBar/ScoreNum.text = str(new_score)
	$EndScreen/Label.text = str(new_score)
#	$ProgressBar/Highscore.text = "Highscore: " + str(new_highscore)
	

func start_game():
	$StartTimer/Countdown.show()
	$StartTimer.start()

func screen_shake():
	globs.emit_signal("walk_screen_shake")
