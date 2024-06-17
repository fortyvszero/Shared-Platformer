extends Sprite2D

@export var direction = Vector2(1, 0)
@export var speed = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	if direction.x < 0:
		flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(direction * speed * delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_2d_body_entered(body):
	print("TODO: remove me. I've hit: ", body)
	queue_free()
