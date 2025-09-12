extends Node2D


@export var Tilemap:TileMapLayer
@export var player :CharacterBody2D
var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
@onready var enemy_container: Node = $enemy_container

const DUNGEON_WIDTH:int = 80
const DUNGEON_HEIGHT:int = 80

enum  TileType {EMPTY,FLOOR,WALL}
var dungeon_grid = []
var curr_room

var room_name = {}
func _ready() -> void:
	create_dungeon()
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		print(curr_room," ", room_name)
func generate_dungeon():
	dungeon_grid = []
	
	for y in DUNGEON_HEIGHT:
		dungeon_grid.append([])
		for x in DUNGEON_WIDTH:
			dungeon_grid[y].append(TileType.EMPTY)
	
	var rooms: Array[Rect2] = []
	var max_attemps = 100
	var tries = 0
	
	while rooms.size() < 4 and tries < max_attemps:
		var w = randi_range(8, 16)
		var h = randi_range(8, 16)
		var x = randi_range(1, DUNGEON_WIDTH - w - 1)
		var y = randi_range(1, DUNGEON_HEIGHT - h - 1)
		var room = Rect2(x,y,w,h)
		spawn_enemy(room.get_center().x,room.get_center().y)
		var overlaps = false
		for other in rooms:
			if room.grow(1).intersects(other):
				overlaps = true
				break
		
		if !overlaps:
			rooms.append(room)
			for iy in range(y,y+h):
				for ix in range(x,x+w):
					dungeon_grid[iy][ix] = TileType.FLOOR
			if rooms.size() > 1:
				var prev = rooms[rooms.size() -2].get_center()
				var curr = room.get_center()
				cave_corridor(prev,curr)
		
		tries += 1
	for i in rooms:
		room_name["room_number"] = rooms.size()
		room_name["coord"] = rooms
	return rooms
func render_dungeon():
	Tilemap.clear()
	
	for y in range(DUNGEON_HEIGHT):
		for x in range(DUNGEON_WIDTH):
			var tile = dungeon_grid[y][x]
			
			match tile:
				TileType.FLOOR: Tilemap.set_cell(Vector2i(x,y),0,Vector2i(1,1))
				TileType.WALL: Tilemap.set_cell(Vector2i(x,y),0,Vector2i(1,16))

func cave_corridor(from:Vector2, to:Vector2,with:int = 2):
	var min_width = -with/2
	var max_width = with/2
	
	if randf() < 0.5:
		for x in range(min(from.x,to.x),max(from.x, to.x) +1):
			for offset in range(min_width,max_width + 1):
				var y = from.y + offset
				if is_in_bounds(x,y):
					dungeon_grid[y][x] = TileType.FLOOR
		for y in range(min(from.y,to.y),max(from.y, to.y) +1):
			for offset in range(min_width,max_width + 1):
				var x = from.x + offset
				if is_in_bounds(x,y):
					dungeon_grid[y][x] = TileType.FLOOR
	else :
		for y in range(min(from.y,to.y),max(from.y, to.y) +1):
			for offset in range(min_width,max_width + 1):
				var x = from.x + offset
				if is_in_bounds(x,y):
					dungeon_grid[y][x] = TileType.FLOOR
		for x in range(min(from.x,to.x),max(from.x, to.x) +1):
			for offset in range(min_width,max_width + 1):
				var y = from.y + offset
				if is_in_bounds(x,y):
					dungeon_grid[y][x] = TileType.FLOOR
func is_in_bounds(x:int,y:int) -> bool:
	return x >= 0 and y >= 0 and x < DUNGEON_WIDTH and y < DUNGEON_HEIGHT

func add_walls():
	for y in range(DUNGEON_HEIGHT):
		for x in range(DUNGEON_WIDTH):
			if dungeon_grid[y][x] == TileType.FLOOR:
				for dy in range(-1,2):
					for dx in range(-1,2):
						var nx = x + dx
						var ny = y + dy
						
						if nx >= 0 and ny >=0 and nx < DUNGEON_WIDTH and ny < DUNGEON_HEIGHT:
							if dungeon_grid[ny][nx] == TileType.EMPTY:
								dungeon_grid[ny][nx] = TileType.WALL

func place_player(rooms:Array[Rect2]):
	curr_room = rooms.pick_random().get_center() * 16
	player.position = curr_room
func create_dungeon():
	place_player(generate_dungeon())
	add_walls()
	render_dungeon()
func spawn_enemy(x,y):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(x * 16,y *16)
	enemy_container.add_child(enemy)
