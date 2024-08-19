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
@onready var teleport_arrow = preload("res://teleport_arrow.tscn")
@onready var light_arrow = preload("res://light_arrow.tscn")
@export var arrow_speed = 1000

enum ARROW_TYPE {BASIC, TELEPORT, LIGHT}
var inventory = {ARROW_TYPE.BASIC: 20, ARROW_TYPE.TELEPORT: 5, ARROW_TYPE.LIGHT: 5}
var equipped_arrow = ARROW_TYPE.BASIC

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
	
	if velocity.x == 0:
		# TODO - Make the player (bow and arrow part) face the mouse
		# Likely need to split the sprite up into 2 parts :/
		if get_global_mouse_position().x < position.x and not facing_left:
			# Mouse on left of player and facing right, flip
			flip_left()
		elif get_global_mouse_position().x > position.x and facing_left:
			# Mouse on right of player and facing left, flip
			flip_right()
	elif facing_left and velocity.x > 0:
		flip_right()
	elif not facing_left and velocity.x < 0:
		flip_left()

	if not attacking and Input.is_action_just_pressed("attack"):
		$AnimationTree["parameters/playback"].start("load_arrow")
		attacking = true
		attack_timer.start()

	if attacking and Input.is_action_just_released("attack"):
		attack_finish()

	# little hack to force the attack animation to play
	# because occasionally it was getting stuck in an attacking state
	var anim = $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	#if attacking and not anim.get_current_node() == "load_arrow":
		#$AnimationTree["parameters/playback"].start("load_arrow")
		
	if !attacking and is_on_floor() and velocity.y == 0 and velocity.x != 0:
		$AnimationTree["parameters/playback"].travel("run")
	
	if !attacking and velocity == Vector2.ZERO:
		$AnimationTree["parameters/playback"].travel("idle")
		
	if (last_fired_arrow != null and last_fired_arrow.can_teleport) and (prev_frame_arrow == null or not prev_frame_arrow.can_teleport):
		SignalBus.can_teleport_to_arrow.emit()
		canTeleport = true
		
	if (last_fired_arrow == null or not last_fired_arrow.can_teleport) and canTeleport:
		SignalBus.cant_teleport_to_arrow.emit()
		canTeleport = false
	
	prev_frame_arrow = last_fired_arrow

func flip_left():
	$AnimatedSprite2D.flip_h = true
	$AnimatedSprite2D.offset.x = -6
	facing_left = true

func flip_right():
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.offset.x = 0
	facing_left = false


func attack_finish():
	attacking = false
	var _arrow: Node
	match equipped_arrow:
		ARROW_TYPE.BASIC:
			_arrow = arrow.instantiate()
		ARROW_TYPE.LIGHT:
			_arrow = light_arrow.instantiate()
		ARROW_TYPE.TELEPORT:
			_arrow = teleport_arrow.instantiate()

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
		
	$AnimationTree["parameters/playback"].start("fire_arrow")
	get_parent().add_child(_arrow)

func handle_input():
	# no movement if attacking
	if not attacking:
		super()
	# keep momentum if jumping
	elif is_on_floor():
		acc.x = 0
		
	if Input.is_action_just_pressed("teleport"):
		if last_fired_arrow != null and last_fired_arrow.can_teleport:
			$AnimationPlayer.play("teleport")
			position = last_fired_arrow.position
			last_fired_arrow.remove()
			
	if Input.is_action_just_pressed("equip_basic_arrow"):
		equipped_arrow = ARROW_TYPE.BASIC
	elif Input.is_action_just_pressed("equip_teleport_arrow"):
		equipped_arrow = ARROW_TYPE.TELEPORT
	elif Input.is_action_just_pressed("equip_light_arrow"):
		equipped_arrow = ARROW_TYPE.LIGHT

func _on_attack_timer_timeout():
	if attack_strength <= 0.9:
		attack_strength += 0.1
	
	if attacking:
		attack_timer.start()

