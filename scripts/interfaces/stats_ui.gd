extends Control

@onready var health_label: Label = $VBoxContainer/health_label
@onready var attack_label: Label = $VBoxContainer/attack_label
@onready var crit_label: Label = $VBoxContainer/crit_label
@onready var gold_label: Label = $VBoxContainer/gold_label


@export var player:CharacterBody2D


func _process(delta: float) -> void:
	health_label.text = "health: " + str(player.current_health)
	attack_label.text = "attack: " + str(player.current_attack)
	crit_label.text = "crit rate: " + str(player.current_crit_chance)
	gold_label.text = "Gold:" + str(player.gold)
