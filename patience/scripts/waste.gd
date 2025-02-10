extends Node2D

@onready var reserve_cards: Node2D = $ReserveCards
@onready var second_card: Node2D = $SecondCard
@onready var first_card: Node2D = $FirstCard

func _process(_delta: float):
	if first_card.get_child_count() == 0 and second_card.get_child_count() == 1:
		var card = second_card.get_child(0)
		second_card.remove_child(card)
		first_card.add_child(card)
		card.is_dragging_blocked = false
	if second_card.get_child_count() == 0 and reserve_cards.get_child_count() > 0:
		var card = reserve_cards.get_child(reserve_cards.get_child_count() - 1)
		reserve_cards.remove_child(card)
		second_card.add_child(card)

func add_card(card: Node2D) -> void:
	move_second_to_reserve()
	move_first_to_second()
	first_card.add_child(card)
	card.is_dragging_blocked = false
	card.flip()
	
func remove_card(card: Node2D) -> void:
	first_card.remove_child(card)
	move_second_to_first()
	move_reserve_to_second()
	
func move_first_to_second():
	var old_first_card = first_card.get_child(0) if first_card.get_child_count() > 0 else null
	if old_first_card != null:
		first_card.remove_child(old_first_card)
		second_card.add_child(old_first_card)
		old_first_card.is_dragging_blocked = true

func move_second_to_reserve():
	var old_second_card = second_card.get_child(0) if second_card.get_child_count() > 0 else null
	if old_second_card != null:
		second_card.remove_child(old_second_card)
		reserve_cards.add_child(old_second_card)
		
func move_second_to_first():
	var old_second_card = second_card.get_child(0) if second_card.get_child_count() > 0 else null
	if old_second_card != null:
		second_card.remove_child(old_second_card)
		first_card.add_child(old_second_card)
		old_second_card.is_dragging_blocked = false
		
func move_reserve_to_second():
	var old_reserve_card = reserve_cards.get_child(reserve_cards.get_child_count()-1) if reserve_cards.get_child_count() > 0 else null
	if old_reserve_card != null:
		reserve_cards.remove_child(old_reserve_card)
		second_card.add_child(old_reserve_card)
