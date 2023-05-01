extends Sprite2D

signal cured


func _on_area_2d_area_entered(area):
	var car = area.get_parent()
	if car.holding != null and !is_in_group("cured"):
		car.delivered = true
		car.holding.queue_free()
		car.holding = null
		$AnimationPlayer.play("cured")
		car.delivered = false
		add_to_group("cured")
		emit_signal("cured")
