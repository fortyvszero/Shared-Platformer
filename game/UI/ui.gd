class_name GameUI
extends CanvasLayer

@export var HeartFullImage : Texture2D
@export var HeartEmptyImage : Texture2D

@onready var arrow_tex: TextureRect = $MarginContainer/VBoxContainer/ArrowTex
@onready var heart_tex_1: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/HeartTex1
@onready var heart_tex_2: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/HeartTex2
@onready var heart_tex_3: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/HeartTex3


func _ready() -> void:
	SignalBus.can_teleport_to_arrow.connect(_on_can_teleport)
	SignalBus.cant_teleport_to_arrow.connect(_on_cant_teleport)
	SignalBus.hero_health_changed.connect(_on_hero_health_change)
	
func _on_can_teleport() -> void:
	arrow_tex.show()
	

func _on_cant_teleport() -> void:
	arrow_tex.hide()

func _on_hero_health_change(remainingHP: int) -> void: # so hacky lol but will do 
	heart_tex_1.texture = HeartEmptyImage
	heart_tex_2.texture = HeartEmptyImage
	heart_tex_3.texture = HeartEmptyImage
	
	if remainingHP >= 1:
		heart_tex_1.texture = HeartFullImage
 	
	if remainingHP >= 2:
		heart_tex_2.texture = HeartFullImage
	
	if remainingHP >= 3:
		heart_tex_3.texture = HeartFullImage
