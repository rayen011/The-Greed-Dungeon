extends Node2D

@export var Tilemap:TileMapLayer
@export var player :CharacterBody2D
var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var room_area_scene = preload("res://scenes/room_detection_area.tscn")
@onready var enemy_container: Node = $enemy_container
@onready var room_area_container: Node = $room_area_container
@onready var deal_interface: Control = %deal_interface
@onready var stats_ui: Control = $UI/stats_ui
@onready var game_over_ui: Control = $UI/Game_over_ui

const DUNGEON_WIDTH:int = 70
const DUNGEON_HEIGHT:int = 70

enum  TileType {EMPTY,FLOOR,WALL,DOOR}
var dungeon_grid = []
var curr_room

var room_nbs:int = 5
var room_w = 16
var room_h = 20

# Store corridor entry points for future doors
var corridor_entries: Array = []

func _ready() -> void:
	create_dungeon()
	Tilemap.add_to_group("Walls") # <- mark all dungeon walls as "Walls"
	stats_ui.player = player
	deal_interface.player = player
	deal_interface.hide()
	player.died.connect(_on_player_died)
	player.entered_room.connect(_on_player_enter_room)

# ---------------------------
# Dungeon Generation
# ---------------------------

func generate_dungeon():
	dungeon_grid = []
	for y in DUNGEON_HEIGHT:
		dungeon_grid.append([])
		for x in DUNGEON_WIDTH:
			dungeon_grid[y].append(TileType.EMPTY)

	var rooms: Array[Rect2] = []
	var max_attempts = 200
	var tries = 0

	while rooms.size() < room_nbs and tries < max_attempts:
		var w = randi_range(room_w, room_h)
		var h = randi_range(room_w, room_h)
		var x = randi_range(1, DUNGEON_WIDTH - w - 1)
		var y = randi_range(1, DUNGEON_HEIGHT - h - 1)
		var room = Rect2(x, y, w, h)

		var overlaps = false
		for other in rooms:
			if room.grow(1).intersects(other):
				overlaps = true
				break

		if !overlaps:
			rooms.append(room)
			_fill_room(room)
			if rooms.size() > 1:
				var prev = rooms[rooms.size() - 2].get_center()
				var curr = room.get_center()
				_fill_corridor(prev, curr)

		tries += 1

	# Add room detection areas and enemies
	for i in range(rooms.size()):
		apply_room_detection(rooms[i].get_center().x, rooms[i].get_center().y, rooms[i].size.x, rooms[i].size.y, i)
		for e in range(randi_range(1, 3)):
			if i > 0:  # skip first room for starting area
				var ex = randf_range(rooms[i].position.x + 2, rooms[i].position.x + rooms[i].size.x - 2)
				var ey = randf_range(rooms[i].position.y + 2, rooms[i].position.y + rooms[i].size.y - 2)
				if dungeon_grid[int(ey)][int(ex)] == TileType.FLOOR:  # smart spawn
					spawn_enemy(ex, ey, i)

	return rooms

# ---------------------------
# Room and Corridor Filling
# ---------------------------

func _fill_room(room: Rect2):
	for iy in range(int(room.position.y), int(room.position.y + room.size.y)):
		for ix in range(int(room.position.x), int(room.position.x + room.size.x)):
			dungeon_grid[iy][ix] = TileType.FLOOR
			Tilemap.set_cell(Vector2i(ix, iy), 0, Vector2i(1, 1))

func _fill_corridor(from: Vector2, to: Vector2, width: int = 2):
	var x1 = int(from.x)
	var y1 = int(from.y)
	var x2 = int(to.x)
	var y2 = int(to.y)

	# Store the corridor entry points (where it touches rooms)
	corridor_entries.append(Vector2(x1, y1))
	corridor_entries.append(Vector2(x2, y2))

	if randf() < 0.5:
		_fill_corridor_horiz(x1, x2, y1, width)
		_fill_corridor_vert(y1, y2, x2, width)
	else:
		_fill_corridor_vert(y1, y2, x1, width)
		_fill_corridor_horiz(x1, x2, y2, width)

func _fill_corridor_horiz(x_start: int, x_end: int, y_center: int, width: int):
	var min_y = max(0, y_center - width / 2)
	var max_y = min(DUNGEON_HEIGHT - 1, y_center + width / 2)
	for x in range(min(x_start, x_end), max(x_start, x_end) + 1):
		for y in range(min_y, max_y + 1):
			dungeon_grid[y][x] = TileType.FLOOR
			Tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))

func _fill_corridor_vert(y_start: int, y_end: int, x_center: int, width: int):
	var min_x = max(0, x_center - width / 2)
	var max_x = min(DUNGEON_WIDTH - 1, x_center + width / 2)
	for y in range(min(y_start, y_end), max(y_start, y_end) + 1):
		for x in range(min_x, max_x + 1):
			dungeon_grid[y][x] = TileType.FLOOR
			Tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))

# ---------------------------
# Walls
# ---------------------------

func add_walls():
	for y in range(DUNGEON_HEIGHT):
		for x in range(DUNGEON_WIDTH):
			if dungeon_grid[y][x] == TileType.FLOOR:
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and ny >= 0 and nx < DUNGEON_WIDTH and ny < DUNGEON_HEIGHT:
							if dungeon_grid[ny][nx] == TileType.EMPTY:
								dungeon_grid[ny][nx] = TileType.WALL
								Tilemap.set_cell(Vector2i(nx, ny), 0, Vector2i(1, 16))

# ---------------------------
# Player & Enemy
# ---------------------------

func place_player(rooms: Array[Rect2]):
	curr_room = rooms[0].get_center() * 16
	player.position = curr_room

func create_dungeon():
	place_player(generate_dungeon())
	add_walls()

func spawn_enemy(x, y, i):
	var enemy = enemy_scene.instantiate()
	enemy.room = i
	enemy.global_position = Vector2(x * 16, y * 16)
	enemy_container.add_child(enemy)

# ---------------------------
# Room Detection
# ---------------------------

func apply_room_detection(x, y, w, h, index):
	var room_area = room_area_scene.instantiate()
	room_area.room_cleared.connect(_on_room_cleared)
	room_area.room_index = index
	room_area.position = Vector2(x * 16, y * 16)
	room_area.size = Vector2(w, h)
	room_area_container.add_child(room_area)

func _on_room_cleared(_index):
	deal_interface.show_upgrade()

func _on_player_died():
	game_over_ui.show_ui()

func _on_player_enter_room(index):
	stats_ui.show_room_number(index)
