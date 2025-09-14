extends Control

@onready var health_label: Label = $VBoxContainer/health_label
@onready var attack_label: Label = $VBoxContainer/attack_label
@onready var crit_label: Label = $VBoxContainer/crit_label
@onready var gold_label: Label = $VBoxContainer/gold_label

@onready var room_enter_label: Label = $room_enter_label
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var player:CharacterBody2D

func _ready() -> void:
	animation_player.play("RESET")

func _process(_delta: float) -> void:
	# Check if the player node is still valid before trying to access its properties.
	# This prevents the "Invalid access" error after the player has been freed.
	if is_instance_valid(player):
		health_label.text = "health: " + str(player.current_health)
		attack_label.text = "attack: " + str(player.current_attack)
		crit_label.text = "crit rate: " + str(player.current_crit_chance)
		gold_label.text = "Gold:" + str(player.gold)
func show_room_number(index):
	room_enter_label.text = "ROOM " + str(index)
	animation_player.play("show")
