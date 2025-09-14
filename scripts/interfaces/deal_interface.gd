extends Control

@onready var chance_label: Label = $Panel/chance_label
@onready var upgrade_type_label: Label = $Panel/upgrade_type_label
@onready var current_stat_label: Label = $Panel/VBoxContainer/current_stat_label
@onready var double_stat_label: Label = $Panel/VBoxContainer/double_stat_label
@onready var lose_label: Label = $Panel/VBoxContainer/lose_label

var upgrade_types = ["double attack","double crit chance","double health","double gold"]
var upgrade_picked: String = ""
var deal_win_rate: float = 1
var player

func _ready() -> void:
	# No need to find the player here, it's passed in from dungeon_generation.gd
	upgrade_picked = upgrade_types.pick_random()

func upgrade_handler(type: String) -> void:
	chance_label.text = "Deal win %: " + str(int(deal_win_rate * 100)) + "%"
	upgrade_type_label.text = type

	if player != null:
		match type:
			"double attack":
				current_stat_label.text = "current attack :" + str(player.current_attack)
				double_stat_label.text = "double attack: " + str(player.current_attack * 2)
				lose_label.text = "Loose: " + str(player.init_attack)
			"double crit chance":
				current_stat_label.text = "Current crit chance : " + str(player.current_crit_chance)
				double_stat_label.text = "Double crit chance : " + str(player.current_crit_chance * 2)
				lose_label.text = "Loose :" + str(player.init_crit_chance)
			"double health":
				current_stat_label.text = "Current max health :" + str(player.current_max_health)
				double_stat_label.text = "Double max health :" + str(player.current_max_health * 2)
				lose_label.text = "Loose :" + str(player.init_max_health)
			"double gold":
				current_stat_label.text = "Current Gold :" + str(player.gold)
				double_stat_label.text = "Double Gold :" + str(player.gold * 2)
				lose_label.text = "Loose :" + str(0)
	else:
		print("Player not found in DealInterface.")


func _on_accept_b_pressed() -> void:
	var win_lose = randf()
	if win_lose <= deal_win_rate:
		if upgrade_picked == "double attack":
			player.current_attack*= 2
		elif upgrade_picked == "double crit chance":
			player.current_crit_chance *= 2
		elif upgrade_picked == "double health":
			player.current_max_health *= 2
			player.current_health = player.current_max_health
		elif upgrade_picked == "double gold":
			player.gold *= 2
	else:
		if upgrade_picked == "double attack":
			player.current_attack = player.init_attack
		elif upgrade_picked == "double crit chance":
			player.current_crit_chance = player.init_crit_chance
		elif upgrade_picked == "double health":
			player.current_max_health = player.init_max_health
			player.current_health = player.init_health
		elif upgrade_picked == "double gold":
			player.gold = 0
	self.hide()

func show_upgrade():
	upgrade_picked = upgrade_types.pick_random()
	visible = true
	upgrade_handler(upgrade_picked)

func _on_cancel_b_pressed() -> void:
	self.hide()
