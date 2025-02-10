extends Node2D

@onready var cards: Node2D = $Cards

var has_mouse: bool = false

func _process(_delta: float) -> void:
	for card in cards.get_children():
		if !card.is_being_dragged:
			card.position = Vector2.ZERO
	
	if !has_mouse: return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	
	var card_being_dragged = Globals.card_being_dragged
	if !can_receive_card(card_being_dragged): return
	
	for card in cards.get_children():
		card.is_dragging_blocked = true
	var card = Globals.card_being_dragged
	card.will_reset_to_drag_position = false
	card.get_parent().remove_child(card)
	cards.add_child(card)
	Globals.card_being_dragged = null

func _on_area_2d_mouse_entered() -> void:
	has_mouse = true

func _on_area_2d_mouse_exited() -> void:
	has_mouse = false
