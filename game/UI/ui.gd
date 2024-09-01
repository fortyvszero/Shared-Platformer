class_name GameUI
extends CanvasLayer

@onready var arrow_tex: TextureRect = $MarginContainer/VBoxContainer/ArrowTex

func _ready() -> void:
	SignalBus.can_teleport_to_arrow.connect(_on_can_teleport)
	SignalBus.cant_teleport_to_arrow.connect(_on_cant_teleport)
	
func _on_can_teleport() -> void:
	arrow_tex.show()
	

func _on_cant_teleport() -> void:
	arrow_tex.hide()
