extends Area2D

signal room_cleared(room_index: int)

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var room_label: Label = $Sprite2D/room_label
@onready var enemy_label: Label = $Sprite2D/enemy_label

var enemy_count: int = 0
var room_index: int
var size: Vector2
var cleared: bool = false
var first_enter: bool = true

@export var cleared_color: Color = Color(0, 1, 0) # default green
@export var default_color: Color = Color(1, 1, 1) # white

func _ready() -> void:
	collision_shape_2d.apply_scale(size)
	sprite_2d.apply_scale(size)
	room_label.text = str(room_index)
	sprite_2d.modulate = default_color
	_update_room_state()

func _process(_delta: float) -> void:
	enemy_label.text = str(enemy_count)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if first_enter:
			first_enter = false
			print("First time entering room:", room_index)
			_update_room_state()
		else:
			print("You entered room:", room_index)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		print("You exited room:", room_index)

func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		enemy_count += 1
		_update_room_state()

func _on_area_exited(area: Area2D) -> void:
	if area is Enemy:
		enemy_count -= 1
		_update_room_state()

func _update_room_state() -> void:
	if not first_enter and enemy_count <= 0:
		if not cleared:
			cleared = true
			sprite_2d.modulate = cleared_color
			print("Room cleared:", room_index)
			emit_signal("room_cleared", room_index)
	else:
		if not cleared:
			sprite_2d.modulate = default_color
