extends Node2D


var messages = [
	"Press any key to begin."
]

var typing_speed = .1
var read_time = 2

var current_message = 0
var display = ""
var current_char = 0

var lore_done = false


func _input(event):
	if lore_done:
		if event is InputEventKey:
			if event.pressed:
				start_game()


func _on_lore_done():
	lore_done = true
	start_dialogue()
	

func start_dialogue():
	current_message = 0
	display = ""
	current_char = 0
	
	$next_char.set_wait_time(typing_speed)
	await get_tree().create_timer(.85).timeout
	$next_char.start()
	

func _on_next_char_timeout():
	if (current_char < len(messages[current_message])):
		var next_char = messages[current_message][current_char]
		display += next_char
		
		$Label.text = display
		current_char += 1
	else:
		$next_char.stop()
		

func start_game():
	get_tree().change_scene_to_packed(preload("res://world.tscn"))
