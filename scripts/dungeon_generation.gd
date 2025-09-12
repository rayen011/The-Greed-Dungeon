extends Node2D


@export var Tilemap:TileMapLayer
@export var player :CharacterBody2D
var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var room_area_scene = preload("res://scenes/room_detection_area.tscn")
@onready var enemy_container: Node = $enemy_container
@onready var room_area_container: Node = $room_area_container

const DUNGEON_WIDTH:int = 70
const DUNGEON_HEIGHT:int = 70

enum  TileType {EMPTY,FLOOR,WALL,DOOR}
var dungeon_grid = []
var curr_room


func _ready() -> void:
	create_dungeon()

		
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
		var w = randi_range(16, 20)
		var h = randi_range(16, 20)
		var x = randi_range(1, DUNGEON_WIDTH - w -1)
		var y = randi_range(1, DUNGEON_HEIGHT - h -1)
		var room = Rect2(x,y,w,h)
		
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
	for i in range(rooms.size()):
		apply_room_detection(rooms[i].get_center().x,rooms[i].get_center().y,rooms[i].size.x,rooms[i].size.y,i)
		for e in range(randi_range(1,3)):
			var ex = randf_range(rooms[i].position.x + 2, rooms[i].position.x + rooms[i].size.x - 2)
			var ey = randf_range(rooms[i].position.y + 2, rooms[i].position.y + rooms[i].size.y - 2)
			spawn_enemy(ex, ey)
	return rooms
func render_dungeon():
	Tilemap.clear()
	
	for y in range(DUNGEON_HEIGHT):
		for x in range(DUNGEON_WIDTH):
			var tile = dungeon_grid[y][x]
			
			match tile:
				TileType.FLOOR: Tilemap.set_cell(Vector2i(x,y),0,Vector2i(1,1))
				TileType.WALL: Tilemap.set_cell(Vector2i(x,y),0,Vector2i(1,16))
				TileType.DOOR: Tilemap.set_cell(Vector2i(x,y),0, Vector2i(4,5))

func cave_corridor(from:Vector2, to:Vector2,with:float = 2.0):
	var min_width:float = -with/2
	var max_width:float = with/2
	
	if randf() < 0.5:
		for x in range(min(from.x,to.x),max(from.x, to.x) +1):
			for offset in range(min_width,max_width + 1):
				var y = from.y + offset
				if is_in_bounds(x,y):
					dungeon_grid[y][x] = TileType.FLOOR
		for y in range(min(from.y,to.y),max(from.y, to.y) +1):
			for offset in range(min_width,max_width + 1):
				var x = to.x + offset
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
				var y = to.y + offset
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
	curr_room = rooms[0].get_center() * 16
	player.position = curr_room
func create_dungeon():
	place_player(generate_dungeon())
	add_walls()
	render_dungeon()
func spawn_enemy(x,y):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(x * 16,y *16)
	enemy_container.add_child(enemy)
func apply_room_detection(x,y,w,h,index):
	var room_area = room_area_scene.instantiate()
	room_area.room_index = index
	room_area.position = Vector2(x *16,y*16)
	room_area.size = Vector2(w,h)
	room_area_container.add_child(room_area)
	
