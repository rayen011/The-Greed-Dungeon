extends CharacterBody2D

const WALK_SPEED = 200.0
const SPRINT_SPEED = 350.0


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

func _physics_process(delta: float) -> void:
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
