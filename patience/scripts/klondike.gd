extends Node2D

@export var card_scene: PackedScene

@onready var cards: Node2D = $Cards
@onready var stock: Node2D = $Stock
@onready var depots: Node2D = $Depots

@onready var seed_label: Label = $SeedLabel
@onready var reset: Button = $Reset

func _ready() -> void:
	var new_cards: Array[Node2D] = []
	
	for suit: int in range(4):
		for value: int  in range(13):
			var card: Node2D = card_scene.instantiate()
			cards.add_child(card)
			card.setup(value as Enums.Value, suit as Enums.Suit)
			card.flip()
			new_cards.append(card)
			
	var new_seed: String = ""
	for i in range(8):
		new_seed += "%x" % [randi_range(0, 15)]
	seed(new_seed.hash())
	seed_label.text = new_seed
	
	new_cards.shuffle()
	
	for depot_number: int in range(depots.get_child_count()):
		var depot: Node2D = depots.get_children()[depot_number]
		var previous_card: Node2D = null
		for card_count: int in range(depot_number+1):
			var card: Node2D = new_cards[0]
			card.depot = depot
			new_cards.remove_at(0)
			if previous_card != null:
				previous_card.child_card = card
				card.parent_card = previous_card
			previous_card = card
			if card_count == depot_number:
				card.dragging_blocked = false
				card.flip()
			card.z_index += card_count
			card.post_drag_position = stock.global_position
			card.pre_drag_position = Vector2(depot.global_position.x, depot.global_position.y + card_count * 40)
			card.returning_to_pre_drag_position = true
	
	for card: Node2D in new_cards:
		cards.remove_child(card)
		stock.cards.add_child(card)

func _process(_delta: float) -> void:
	for foundation: Node2D in find_child("Foundations").get_children():
		foundation.find_child("OutlineSprite").material.set_shader_parameter('width', 0)
	for depot: Node2D in find_child("Depots").get_children():
		depot.find_child("OutlineSprite").material.set_shader_parameter('width', 0)

func _on_reset_button_down() -> void:
	get_tree().reload_current_scene()
