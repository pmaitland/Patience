extends Node2D

@export var card_scene: PackedScene

@onready var cards: Node2D = $Cards
@onready var stock: Node2D = $Stock
@onready var depots: Node2D = $Depots

func _ready() -> void:
	var new_cards: Array[Node2D] = []
	
	for suit in range(4):
		for value in range(13):
			var card = card_scene.instantiate()
			card.name = "Card%s-%s" % [suit, value]
			card.suit = suit as Enums.Suit
			card.value = value as Enums.Value
			card.dragging_blocked = true
			cards.add_child(card)
			new_cards.append(card)
			card.flip()
	new_cards.shuffle()
	
	for depot_number in range(depots.get_child_count()):
		var depot = depots.get_children()[depot_number]
		var previous_card: Node2D = null
		for card_count in range(depot_number+1):
			var card = new_cards[0]
			card.global_position = Vector2(depot.global_position.x, depot.global_position.y + card_count * 10)
			card.in_depot = true
			new_cards.remove_at(0)
			if previous_card != null:
				previous_card.child_card = card
				card.parent_card = previous_card
			previous_card = card
			if card_count == depot_number:
				card.dragging_blocked = false
				card.flip()
	
	for card in new_cards:
		cards.remove_child(card)
		stock.cards.add_child(card)
