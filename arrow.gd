class_name Arrow
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

func _on_area_2d_body_entered(body):
	var enemy = body as Enemy
	
	if enemy:
		enemy.damage(1)
	remove()

func remove() -> void:
	queue_free()
