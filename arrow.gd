class_name Arrow
extends RigidBody2D

@export var direction = Vector2(1, 0)
@export var max_speed = 500
@export var rotation_inertia = 1000
@export var strength: float
var last_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	fire_to_mouse()

func _physics_process(delta):
	detect_collisions()


func _integrate_forces(state):
	rotate_arrow(state)


func fire_to_mouse():
	last_pos = position
	look_at(get_global_mouse_position())
	apply_central_impulse(((get_global_mouse_position() - get_position()).normalized() * max_speed * strength))


# Needed to rotate the arrow. Note the centre of mass is set to the tip of the arrow
# Setting this number was trial and error - perhaps there is a better way?
func rotate_arrow(state):
	state.apply_torque(get_angle_to(last_pos) * -rotation_inertia)
	last_pos = position

# contact monitor must be true and max contacts high enough
func detect_collisions():
	var collisions = get_colliding_bodies()
	if len(collisions) > 0:
		set_freeze_enabled(true)
		for collision in collisions:
			var enemy = collision as Enemy
			if enemy:
				enemy.damage(1)
				remove()


func remove() -> void:
	queue_free()
