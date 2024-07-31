class_name AreaTriggeredLabel
extends Label


func _on_area_2d_body_entered(body: Node2D) -> void:
	var hero = body as Hero
	
	if hero:
		var tween = create_tween()
		
		tween.tween_property(self, "modulate:a", 1, 0.5)
		tween.set_ease(Tween.EASE_IN)
		
		await tween.finished


func _on_area_2d_body_exited(body: Node2D) -> void:
	var hero = body as Hero
	
	if hero:
		var tween = create_tween()
		
		tween.tween_property(self, "modulate:a", 0, 0.5)
		tween.set_ease(Tween.EASE_IN)
		
		await tween.finished
