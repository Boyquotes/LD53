extends Node2D

signal lore_done


var messages = ["You have been hired from the Gods to oppose death. You have been given Truck, a living assistant to help you gather and deliver souls to the dying in the city of Knubrec."]

var typing_speed = .065
var read_time = 2

var current_message = 0
var display = ""
var current_char = 0

func _ready():
	start_dialogue()
	

func start_dialogue():
	current_message = 0
	display = ""
	current_char = 0
	
	$next_char.set_wait_time(typing_speed)
	$next_char.start()
	

func _on_next_char_timeout():
	if (current_char < len(messages[current_message])):
		var next_char = messages[current_message][current_char]
		display += next_char
		
		$Label.text = display
		current_char += 1
	else:
		$next_char.stop()
		emit_signal("lore_done")
