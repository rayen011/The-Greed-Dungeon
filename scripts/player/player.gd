extends CharacterBody2D
class_name Player

signal died
signal entered_room(index)

const WALK_SPEED = 500
const SPRINT_SPEED = 1000

# --- Base stats ---
@export var init_attack: float
@export var init_max_health: float
@export var init_health: float
@export var init_crit_chance: float
@export var gold: int

# --- Projectile ---
@export var projectile_scene: PackedScene
@onready var projectile_container: Node = $ProjectileContainer

# --- Primary Weapon ---
@export_group("Primary Weapon (p1)")
@export var p1_attack_speed: float = 0.5
@export var p1_bullet_count: int = 1
@export var p1_bullet_spread: float = 5.0

# --- Secondary Weapon ---
@export_group("Secondary Weapon (p2)")
@export var p2_attack_speed: float = 1.0
@export var p2_bullet_count: int = 5
@export var p2_bullet_spread: float = 10.0

# --- UI ---
@onready var health_bar: ProgressBar = $HealthBar
@onready var reload_bar: ProgressBar = $reload_bar

# --- Other Nodes ---
@onready var hit_box: Area2D = $hit_box
@onready var fire_rate_timer: Timer = $FireRateTimer

# --- Runtime stats ---
var current_attack: float
var current_max_health: float
var current_health: float
var current_crit_chance: float

var room: int
var zoom: bool = true:
	set(value):
		zoom = value
		$Camera2D.zoom = Vector2(3, 3) if value else Vector2(0.5, 0.5)

var velocity_input: Vector2 = Vector2.ZERO
var facing_dir: String = "down"
var has_bomb: bool = true
var is_sprinting: bool = false
var can_fire: bool = true

# Which weapon is active? "p1" or "p2"
var active_weapon: String = "p1"


func _ready() -> void:
	add_to_group("Player")

	# Init player stats
	current_attack = init_attack
	current_max_health = init_max_health
	current_health = init_health
	current_crit_chance = init_crit_chance

	health_bar.max_value = current_max_health
	health_bar.value = current_health

	# Init with primary weapon stats
	_switch_weapon("p1")


func _physics_process(_delta: float) -> void:
	# Reload UI
	if not can_fire:
		reload_bar.value = reload_bar.max_value - fire_rate_timer.time_left
	else:
		reload_bar.value = reload_bar.max_value

	handle_input()
	move_and_slide()

	# Zoom toggle
	if Input.is_action_just_pressed("zoom"):
		zoom = not zoom

	# Weapon swap
	if Input.is_action_just_pressed("p1"):
		_switch_weapon("p1")
	if Input.is_action_just_pressed("p2"):
		_switch_weapon("p2")

	# Shooting with mouse
	if Input.is_action_pressed("shoot") and can_fire:
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position).normalized()
		fire(dir)

	# Health bar update
	health_bar.value = current_health


func _switch_weapon(which: String) -> void:
	active_weapon = which
	if active_weapon == "p1":
		fire_rate_timer.wait_time = p1_attack_speed
		reload_bar.max_value = p1_attack_speed
	elif active_weapon == "p2":
		fire_rate_timer.wait_time = p2_attack_speed
		reload_bar.max_value = p2_attack_speed


func fire(direction: Vector2) -> void:
	if not can_fire:
		return

	var base_dir = direction.normalized()
	var bullet_count = (p1_bullet_count if active_weapon == "p1" else p2_bullet_count)
	var bullet_spread = (p1_bullet_spread if active_weapon == "p1" else p2_bullet_spread)
	var half = (bullet_count - 1) / 2.0

	for i in range(bullet_count):
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.damage = current_attack

		var angle_offset = deg_to_rad((i - half) * bullet_spread)
		projectile.direction = base_dir.rotated(angle_offset)

		projectile_container.add_child(projectile)

	can_fire = false
	fire_rate_timer.start()


func handle_input() -> void:
	velocity_input = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	is_sprinting = Input.is_action_pressed("sprint")
	var speed = SPRINT_SPEED if is_sprinting else WALK_SPEED

	if velocity_input != Vector2.ZERO:
		velocity_input = velocity_input.normalized()
		velocity = velocity_input * speed

		if abs(velocity_input.x) > abs(velocity_input.y):
			facing_dir = "right" if velocity_input.x > 0 else "left"
		else:
			facing_dir = "down" if velocity_input.y > 0 else "up"
	else:
		velocity = Vector2.ZERO


func _on_fire_rate_timer_timeout() -> void:
	can_fire = true


func take_damage(damage_amount: float) -> void:
	current_health -= damage_amount
	health_bar.value = current_health
	if current_health <= 0:
		died.emit()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Enemy and area.has_method("deal_damage"):
		var damage_dealt = area.deal_damage()
		take_damage(damage_dealt)
		print("Player took damage: ", damage_dealt)

	if area is Room_area:
		entered_room.emit(area.room_index)
