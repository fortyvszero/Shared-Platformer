class_name Enemy
extends CharacterBody2D

@onready var shader_player: AnimationPlayer = $ShaderPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var movable_ground_cast: RayCast2D = $MovableGroundCast

@export var max_health := 3
var current_health

const SPEED = 2000.0
const JUMP_VELOCITY = -400.0

var moveDir = Vector2.RIGHT

func _ready() -> void:
	current_health = max_health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func damage(dmg : int) -> void:
	current_health -= dmg
	shader_player.play("hit_flash")
	
	if current_health <= 0:
		kill()


func kill() -> void:
	await get_tree().create_timer(0.5).timeout
	shader_player.play("dissolve")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = SPEED * moveDir.x * delta
	
	if is_on_wall() or !movable_ground_cast.is_colliding():
		moveDir = -moveDir
		sprite_2d.flip_h = !sprite_2d.flip_h
		movable_ground_cast.target_position.x = -movable_ground_cast.target_position.x
		
	move_and_slide()


func _on_shader_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dissolve":
		queue_free()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	var player = body as Hero
	
	if player:
		player.damage()
