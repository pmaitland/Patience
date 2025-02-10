extends Node2D

var has_mouse: bool = false

#func _process(_delta: float) -> void:
	#for card_number in range(cards.get_child_count()):
		#var card = cards.get_children()[card_number]
		#if !card.is_being_dragged:
			#card.position.y = card_number * 20
		#if card_number == cards.get_child_count() - 1:
			#if !card.is_face_up:
				#card.flip()
			#if card.is_dragging_blocked:
				#card.is_dragging_blocked = false
	#
	#if !has_mouse: return
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	#
	#var card_being_dragged = Globals.card_being_dragged
	#if !can_receive_card(card_being_dragged): return
	#
	#for card in cards.get_children():
		#card.is_dragging_blocked = true
	#card_being_dragged.will_reset_to_drag_position = false
	#card_being_dragged.get_parent().remove_child(card_being_dragged)
	#cards.add_child(card_being_dragged)
	#Globals.card_being_dragged = null

#func can_receive_card(card: Node2D) -> bool:
	#if card == null: return false
	#var top_card = cards.get_child(cards.get_child_count()-1) if cards.get_child_count() > 0 else null
	#return top_card == null and card.value == Enums.Value.KING
#
#func add_card(card: Node2D) -> void:
	#if card.get_parent() != null:
		#card.get_parent().remove_child(card)
	#cards.add_child(card)

func _on_area_2d_mouse_entered() -> void:
	has_mouse = true

func _on_area_2d_mouse_exited() -> void:
	has_mouse = false
