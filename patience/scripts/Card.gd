extends Node2D

@onready var value_label: Label = $ValueLabel
@onready var suit_label: Label = $SuitLabel
@onready var front_sprite: Sprite2D = $FrontSprite
@onready var back_sprite: Sprite2D = $BackSprite

@export var value: Enums.Value
@export var suit: Enums.Suit

var is_face_up: bool = true

var last_mouse_position: Vector2 = Vector2.ZERO
var has_mouse: bool = false
var is_dragging_blocked: bool = false
var pre_drag_position: Vector2 = position
var will_reset_to_drag_position: bool = true
var is_being_dragged: bool = false
var parent_card: Node2D = null
var child_card: Node2D = null

var colliding_cards: Array[Node2D] = []
var colliding_foundations: Array[Node2D] = []
var colliding_depots: Array[Node2D] = []

var in_depot: bool = false
var in_foundation: bool = false

const z_index_change_when_dragged = 1000

func _ready() -> void:
	match value:
		Enums.Value.ACE:
			value_label.text = "A"
		Enums.Value.KING:
			value_label.text = "🤴"
		Enums.Value.QUEEN:
			value_label.text = "👸"
		Enums.Value.JACK:
			value_label.text = "🎃"
		Enums.Value.TEN:
			value_label.text = "X"
		_:
			value_label.text = str(value+1)
	match suit:
		Enums.Suit.SPADES:
			suit_label.text = "♠"
		Enums.Suit.HEARTS:
			suit_label.text = "♥"
		Enums.Suit.DIAMONDS:
			suit_label.text = "♦"
		Enums.Suit.CLUBS:
			suit_label.text = "♣"

func _process(_delta: float) -> void:
	var current_mouse_position = get_global_mouse_position()
	
	if can_be_dragged():
		set_is_being_dragged(true)
		pre_drag_position = global_position
		will_reset_to_drag_position = true
		scale = Vector2(1.2, 1.2)
		z_index += z_index_change_when_dragged
		Globals.card_being_dragged = self
		
	if is_being_dragged:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position.x += current_mouse_position.x - last_mouse_position.x
			global_position.y += current_mouse_position.y - last_mouse_position.y
		else:
			if !colliding_cards.is_empty():
				var moved = false
				for card in colliding_cards:
					if can_pile_in_depot(card) or can_pile_in_foundation(card):
						if parent_card != null:
							parent_card.child_card = null
							parent_card.is_dragging_blocked = false
							if !parent_card.is_face_up:
								parent_card.flip()
						card.child_card = self
						parent_card = card
						if parent_card.in_depot:
							in_depot = true
							in_foundation = false
						if parent_card.in_foundation:
							in_foundation = true
							in_depot = false
						if "FirstCard" in get_parent().name:
							var cards = get_tree().root.get_node("Klondike/Cards")
							get_parent().get_parent().remove_card(self)
							cards.add_child(self)
						moved = true
						break
				if !moved:
					global_position = pre_drag_position
			elif !colliding_depots.is_empty():
				if parent_card != null:
					parent_card.child_card = null
					parent_card.is_dragging_blocked = false
					if !parent_card.is_face_up:
						parent_card.flip()
				parent_card = null
				var new_position = colliding_depots[0].global_position
				in_depot = true
				in_foundation = false
				if "FirstCard" in get_parent().name:
					var cards = get_tree().root.get_node("Klondike/Cards")
					get_parent().get_parent().remove_card(self)
					cards.add_child(self)
				global_position = new_position
			elif !colliding_foundations.is_empty():
				if parent_card != null:
					parent_card.child_card = null
					parent_card.is_dragging_blocked = false
					if !parent_card.is_face_up:
						parent_card.flip()
				parent_card = null
				var new_position = colliding_foundations[0].global_position
				in_depot = false
				in_foundation = true
				if "FirstCard" in get_parent().name:
					var cards = get_tree().root.get_node("Klondike/Cards")
					get_parent().get_parent().remove_card(self)
					cards.add_child(self)
				global_position = new_position
			else:
				global_position = pre_drag_position
				
			set_is_being_dragged(false)
			scale = Vector2(1, 1)
			z_index -= z_index_change_when_dragged
			Globals.card_being_dragged = null
			
	if parent_card != null and !is_being_dragged:
		scale = parent_card.scale
		z_index = parent_card.z_index + 1
		global_position = Vector2(parent_card.global_position.x, parent_card.global_position.y)
		if !parent_card.in_foundation:
			global_position.y += 20
		
	last_mouse_position = current_mouse_position
	
func can_be_dragged() -> bool:
	return !is_dragging_blocked \
		and has_mouse \
		and Globals.card_being_dragged == null \
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
func flip() -> void:
	is_face_up = !is_face_up
	if is_face_up:
		front_sprite.visible = true
		value_label.visible = true
		suit_label.visible = true
		back_sprite.visible = false
	else:
		front_sprite.visible = false
		value_label.visible = false
		suit_label.visible = false
		back_sprite.visible = true
		
func can_pile_in_depot(card: Node2D) -> bool:
	return card.value == value + 1 and (card.suit == (suit + 1) % 4 or card.suit == (suit + 3) % 4)
	
func can_pile_in_foundation(card: Node2D) -> bool:
	return child_card == null and card.value == value - 1 and card.suit == suit

func _on_area_2d_mouse_entered() -> void:
	has_mouse = true

func _on_area_2d_mouse_exited() -> void:
	has_mouse = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if !is_being_dragged: return
	var parent = area.get_parent()
	if "Card" in parent.name and !parent.is_being_dragged and parent.is_face_up and (parent.in_depot or parent.in_foundation):
		colliding_cards.append(parent)
	elif "Foundation" in parent.name and value == Enums.Value.ACE:
		colliding_foundations.append(parent)
	elif "Depot" in parent.name and value == Enums.Value.KING:
		colliding_depots.append(parent)

func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent in colliding_cards:
		colliding_cards.remove_at(colliding_cards.find(parent))
	elif parent in colliding_foundations:
		colliding_foundations.remove_at(colliding_foundations.find(parent))
	elif parent in colliding_depots:
		colliding_depots.remove_at(colliding_depots.find(parent))

func set_is_being_dragged(new_value: bool) -> void:
	is_being_dragged = new_value
	if child_card != null:
		child_card.set_is_being_dragged(new_value)
