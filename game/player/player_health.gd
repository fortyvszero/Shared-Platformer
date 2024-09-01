class_name PlayerHealth
extends Node

signal health_changed(amount : int, remaining : int)
signal health_depleted

## Maximum total health, the upper cap for a health value
@export var MaxHealth : int = 3
 
## True if at full health; else false
var IsMaxHealth : bool

## Current health. If this goes below zero the actor dies
var _currentHealth : int

func _ready() -> void:
	set_max(MaxHealth)
	

func set_max(newMax : int) -> void:
	MaxHealth = newMax
	_currentHealth = MaxHealth
	
	health_changed.emit(0, _currentHealth)

func change_health(amount : int) -> void:
	_currentHealth = clamp(_currentHealth - amount, 0, MaxHealth)
	health_changed.emit(amount, _currentHealth)
	
	IsMaxHealth = _currentHealth == MaxHealth
	
	if _currentHealth <= 0:
		health_depleted.emit()
