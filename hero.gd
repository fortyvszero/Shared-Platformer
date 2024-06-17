extends "res://platformer_controller/platformer_controller.gd"


var facing_left = false
var attacking = false
@onready var arrow = preload("res://arrow.tscn")
@export var arrow_speed = 1000

func _on_hit_ground():
	$AnimationTree["parameters/playback"].travel("land")

func _on_jumped(_is_ground_jump):
	$AnimationTree["parameters/playback"].start("jump")

func _process(_delta):
	if not is_on_floor():
		if velocity.y > 0:
			$AnimationTree["parameters/playback"].travel("fall")

	if facing_left and velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.offset.x = 0
		facing_left = false
	elif not facing_left and velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.offset.x = -6
		facing_left = true
		
	
	if not attacking and Input.is_action_just_pressed("attack"):
		$AnimationTree["parameters/playback"].start("attack")
		attacking = true
	
	# little hack to force the attack animation to play
	# because occasionally it was getting stuck in an attacking state
	var anim = $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	if attacking and not anim.get_current_node() == "attack":
		$AnimationTree["parameters/playback"].start("attack")
		
	if is_on_floor() and velocity.y == 0 and velocity.x != 0:
		$AnimationTree["parameters/playback"].travel("run")
	
	if velocity == Vector2.ZERO:
		$AnimationTree["parameters/playback"].travel("idle")


func _on_attack_animation_finished():
	attacking = false
	var _arrow = arrow.instantiate()
	if facing_left:
		_arrow.position = $AnimatedSprite2D/ArrowSpawnPointLeft.global_position
		_arrow.direction = Vector2(-1, 0)
	else:
		_arrow.position = $AnimatedSprite2D/ArrowSpawnPointRight.global_position
		_arrow.direction = Vector2(1, 0)
	get_parent().add_child(_arrow)

func handle_input():
	# no movement if attacking
	if not attacking:
		super()
	# keep momentum if jumping
	elif is_on_floor():
		acc.x = 0
