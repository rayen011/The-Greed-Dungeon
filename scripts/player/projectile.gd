extends Area2D
class_name Projectile

@export var speed: float = 700
@export var damage: float = 1.0
@export var lifetime: float = 3.0

# Weapon behavior modifiers
@export var pierce: bool = false             # If true, projectile doesn't disappear after hit
@export var bounces: int = 0                 # Number of times it can bounce
@export var homing: bool = false             # Will home toward enemy target
@export var homing_strength: float = 0.05    # How strongly it turns toward target (0.0–1.0)
@export var spread_angle: float = 0.0        # Additional spread for multi-shot
@export var knockback_force: float = 0.0     # Optional knockback

var direction: Vector2
var remaining_bounces: int

func _ready() -> void:
	remaining_bounces = bounces

	# Kill timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()


func _physics_process(delta: float) -> void:
	# Movement
	global_position += direction.normalized() * speed * delta

	# Homing logic
	if homing:
		var target = get_closest_enemy()
		if target:
			var to_target = (target.global_position - global_position).normalized()
			direction = direction.lerp(to_target, clamp(homing_strength, 0.0, 1.0)).normalized()


func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		return null

	var closest = enemies[0]
	var closest_dist = global_position.distance_squared_to(closest.global_position)

	for e in enemies:
		var dist = global_position.distance_squared_to(e.global_position)
		if dist < closest_dist:
			closest = e
			closest_dist = dist

	return closest


func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		area.take_damage(damage)

		# Apply knockback if supported
		if knockback_force > 0 and area.has_method("apply_knockback"):
			area.apply_knockback(direction * knockback_force)

		# Handle pierce
		if pierce:
			return
		else:
			queue_free()

	if area.is_in_group("Walls"):
		if remaining_bounces > 0:
			direction = direction.bounce(Vector2.RIGHT) # replace with proper normal
			remaining_bounces -= 1

		# Kill if no bounces remain
		if remaining_bounces <= 0 and !pierce:
			queue_free()
	else:
		if !pierce and remaining_bounces <= 0:
			queue_free()


func _on_timer_timeout() -> void:
	queue_free()
