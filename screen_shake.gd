extends Camera2D


@onready var shake_timer = $shake_timer
@onready var shake_intensity = 0
var default_offset = offset
@export var walk_shake_intensity = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	globs.walk_screen_shake.connect(walk_screen_shake)
	set_process(false)
	randomize()
	
func _process(_delta):
	var shake_vector = Vector2(randf_range(-1, 1) * shake_intensity, randf_range(-1, 1) * shake_intensity)
	var tween = create_tween()
	tween.tween_property(self, "offset", shake_vector, 0.1)
	
func shake(intensity):
	set_process(true)
	shake_intensity = intensity
	shake_timer.start()
	

func _on_shake_timer_timeout():
	set_process(false)
	var tween = create_tween()
	tween.tween_property(self, "offset", default_offset, 0.1)
	

func walk_screen_shake():
	shake(walk_shake_intensity)
