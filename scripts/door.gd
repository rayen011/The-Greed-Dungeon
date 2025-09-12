extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var is_locked: bool = false

func lock():
	is_locked = true
	collider.disabled = false
	modulate = Color(1, 0, 0) # red tint for locked

func unlock():
	is_locked = false
	collider.disabled = true
	modulate = Color(1, 1, 1) # back to normal
