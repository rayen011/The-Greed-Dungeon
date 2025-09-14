extends Area2D
class_name Enemy

@export var init_health: float = 10
@export var damage: float = 2
var health: float
var speed: float = 100
var room: int
var player = null
var can_attack: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var deal_damage_area: Area2D = $hit_box
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	health = init_health
	health_bar.max_value = init_health
	health_bar.value = health


func _process(delta: float) -> void:
	# Enemy only moves if player is in the same room
	if player and player.room == room:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * speed * delta


func take_damage(damage_amount: float) -> void:
	health -= damage_amount
	health_bar.value = health
	if health <= 0:
		spawn_loot()
		# Use deferred to safely remove enemy
		call_deferred("queue_free")


func spawn_loot() -> void:
	var item_data = Loottable.get_random_item()
	if item_data:
		var item_instance = preload("res://scenes/player/item.tscn").instantiate()
		item_instance.item_name = item_data.name
		item_instance.rarity = item_data.rarity
		item_instance.value = item_data.value
		item_instance.global_position = global_position
		# Defer adding to the scene tree
		get_tree().get_root().call_deferred("add_child", item_instance)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Player:
		can_attack = true
		if can_attack and body.has_method("take_damage"):
			body.take_damage(damage)
			attack_cooldown_timer.start()
			can_attack = false


func _on_attack_cooldown_timer_timeout() -> void:
	if player:
		player.take_damage(damage)
	can_attack = true


func _on_hit_box_body_exited(body: Node2D) -> void:
	if body is Player:
		can_attack = false
		attack_cooldown_timer.stop()
