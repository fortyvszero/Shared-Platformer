class_name Hero
extends PlatformerController2D

var last_fired_arrow : Arrow
var prev_frame_arrow : Arrow
var all_arrows : Array[Arrow]
@export var max_arrows_in_scene := 5

var facing_left := false
var attacking := false
var attack_timer : Timer
var attack_strength := 0.1
var canTeleport := false

@onready var arrow = preload("res://arrow.tscn")
@export var arrow_speed = 1000

func _ready():
	attack_timer = $AttackTimer

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
		attack_timer.start()

	if attacking and Input.is_action_just_released("attack"):
		attack_animation_finished()

	# little hack to force the attack animation to play
	# because occasionally it was getting stuck in an attacking state
	var anim = $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	#if attacking and not anim.get_current_node() == "attack":
		#$AnimationTree["parameters/playback"].start("attack")
		
	if is_on_floor() and velocity.y == 0 and velocity.x != 0:
		$AnimationTree["parameters/playback"].travel("run")
	
	if velocity == Vector2.ZERO:
		$AnimationTree["parameters/playback"].travel("idle")
		
	if last_fired_arrow != null and prev_frame_arrow == null:
		SignalBus.can_teleport_to_arrow.emit()
		canTeleport = true
		
	if last_fired_arrow == null and canTeleport:
		SignalBus.cant_teleport_to_arrow.emit()
		canTeleport = false
		print("cant tp")
	
	prev_frame_arrow = last_fired_arrow


func attack_animation_finished():
	attacking = false
	var _arrow = arrow.instantiate()
	_arrow.strength = attack_strength
	attack_timer.stop()
	attack_strength = 0.1
	last_fired_arrow = _arrow
	
	if facing_left:
		_arrow.position = $AnimatedSprite2D/ArrowSpawnPointLeft.global_position
		_arrow.direction = Vector2(-1, 0)
	else:
		_arrow.position = $AnimatedSprite2D/ArrowSpawnPointRight.global_position
		_arrow.direction = Vector2(1, 0)
	
	all_arrows.push_front(_arrow)
	if len(all_arrows) > max_arrows_in_scene:
		if all_arrows[max_arrows_in_scene] != null:
			all_arrows[max_arrows_in_scene].remove()
		all_arrows.pop_at(max_arrows_in_scene)
		
	$AnimationTree["parameters/playback"].start("attack_part_2")
	get_parent().add_child(_arrow)

func handle_input():
	# no movement if attacking
	if not attacking:
		super()
	# keep momentum if jumping
	elif is_on_floor():
		acc.x = 0
		
	if Input.is_action_just_pressed("teleport"):
		if last_fired_arrow != null:
			$AnimationPlayer.play("teleport")
			position = last_fired_arrow.position
			last_fired_arrow.remove()


func _on_attack_timer_timeout():
	if attack_strength <= 0.9:
		attack_strength += 0.1
	
	if attacking:
		attack_timer.start()

