extends CharacterBody2D
class_name Player

const WALK_SPEED = 500
const SPRINT_SPEED = 1000

@export var init_attack:float
@export var init_max_health:float
@export var init_health:float
@export var init_crit_chance:float
@export var gold:int

var current_attack:float
var current_max_health:float
var current_health:float
var current_crit_chance:float


var zoom:bool = true:
	set(value):
		zoom = value
		if value:
			$Camera2D.zoom = Vector2(3,3)
		else:
			$Camera2D.zoom = Vector2(0.5,0.5)

var velocity_input: Vector2 = Vector2.ZERO
var facing_dir: String = "down"   # "up", "down", "left", "right"
var has_bomb: bool = true
var is_sprinting: bool = false
func _ready() -> void:
	current_attack = init_attack
	current_max_health = init_max_health
	current_health = init_health
	current_crit_chance = init_crit_chance
	
func _physics_process(_delta: float) -> void:
	# Handle input
	handle_input()
	move_and_slide()
	if Input.is_action_just_pressed("shoot"):
		zoom = !zoom
	# Handle animations




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

		# Update facing direction (last input axis dominates)
		if abs(velocity_input.x) > abs(velocity_input.y):
			facing_dir = "right" if velocity_input.x > 0 else "left"
		else:
			facing_dir = "down" if velocity_input.y > 0 else "up"
	else:
		velocity = Vector2.ZERO


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Enemy:
		area.queue_free()
