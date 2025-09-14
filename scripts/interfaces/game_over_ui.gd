extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide_ui()



func _on_restart_b_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dungeon_generation.tscn")
	self.hide_ui()

func show_ui():
	self.show()
func hide_ui():
	self.hide()
