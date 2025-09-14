extends Area2D
class_name Item

@export var item_name: String = "Unknown"
@export var rarity: String = "Common"
@export var value: int = 0  # could affect gold, stats, etc.
@export var sprite_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D



func _ready():
	sprite.texture = sprite_texture
