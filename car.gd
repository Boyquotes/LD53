extends CharacterBody2D

signal crashed

var wheel_base = 15 # Distance from front to rear wheel
var steering_angle = 7.5 # Amount that front wheel turns, in degrees
var engine_power = 650
var friction = -0.9 # Negative value because friction opposes motion
var drag = -0.001 # Wind resistance
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var steer_angle

var holding = null
var delivered = false
var alive = true


func _physics_process(delta):
	if alive:
		acceleration = Vector2.ZERO
		get_input()
		apply_friction()
		calculate_steering(delta)
		velocity += acceleration * delta
		move_and_slide()
		
		if position.y <= 35:
			position.y = 670
		elif position.y >= 670:
			position.y = 35
		if position.x <= -22:
			position.x = 1174
		elif position.x >= 1174:
			position.x = -22
		

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag	
	acceleration += drag_force + friction_force
	

func get_input():
	var turn = 0
	if Input.is_action_pressed("move_right"):
		turn += 1
	if Input.is_action_pressed("move_left"):
		turn -= 1
	steer_angle = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
		

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0: # Forwards
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0: # Reverse
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
	

func _on_area_2d_area_entered(area):
	var hit_object = area.get_parent() # Sprite2D
	if hit_object.is_in_group("souls"):
		if !delivered:
			hit_object.hide()
			area.get_child(0).set_deferred("disabled", true)
			holding = area.get_parent()
	elif hit_object.is_in_group("cured"):
		hit_object.get_child(1).play("die")
		await hit_object.get_child(1).animation_finished
		hit_object.queue_free()
		emit_signal("crashed")
