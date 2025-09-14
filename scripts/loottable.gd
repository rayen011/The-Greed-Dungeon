extends Node
class_name LootTable
# You can make this a singleton in Project Settings -> Autoload for easy access.

var item_pool = [
	{"name":"Potion","rarity":"Common","value":10},
	{"name":"Gold Coin","rarity":"Common","value":5},
	{"name":"Sword","rarity":"Rare","value":25},
	{"name":"Epic Staff","rarity":"Epic","value":50},
]

var rarity_chances = {
	"Common": 60,
	"Rare": 30,
	"Epic": 10
}

func get_random_item():
	var roll = randi() % 100
	var cumulative = 0

	for rarity in ["Common","Rare","Epic"]:
		cumulative += rarity_chances[rarity]
		if roll < cumulative:
			var items_of_rarity = item_pool.filter(func(i): return i.rarity == rarity)
			if items_of_rarity.size() > 0:
				return items_of_rarity[randi_range(0, items_of_rarity.size() - 1)]
			break
	return null
