extends Node2D

@onready var value_label: Label = $ValueLabel
@onready var suit_label: Label = $SuitLabel
@onready var front_sprite: Sprite2D = $FrontSprite
@onready var back_sprite: Sprite2D = $BackSprite

var value: Enums.Value
var suit: Enums.Suit

var face_up: bool = true

var has_mouse: bool = false
var dragging_blocked: bool = false
var being_dragged: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO
var pre_drag_position: Vector2 = position

var in_depot: bool = false
var in_foundation: bool = false

var colliding_cards: Array[Node2D] = []
var colliding_foundations: Array[Node2D] = []
var colliding_depots: Array[Node2D] = []

var parent_card: Node2D = null
var child_card: Node2D = null

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
	
	if parent_card != null and !being_dragged:
		z_index = parent_card.z_index + 1
		global_position = Vector2(parent_card.global_position.x, parent_card.global_position.y)
		if !parent_card.in_foundation:
			global_position.y += 20
			
	if trigger_dragging():
		toggle_being_dragged()
		
	if being_dragged:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position.x += current_mouse_position.x - last_mouse_position.x
			global_position.y += current_mouse_position.y - last_mouse_position.y
		else:
			toggle_being_dragged()
			if !colliding_cards.is_empty():
				var moved = false
				for card in colliding_cards:
					if can_pile_in_depot(card) or can_pile_in_foundation(card):
						free_parent()
						parent_card = card
						card.child_card = self
						in_depot = parent_card.in_depot
						in_foundation = parent_card.in_foundation
						check_moved_from_waste()
						moved = true
						break
				if !moved:
					global_position = pre_drag_position
			elif !colliding_depots.is_empty():
				free_parent()
				var new_position = colliding_depots[0].global_position
				in_depot = true
				in_foundation = false
				check_moved_from_waste()
				global_position = new_position
			elif !colliding_foundations.is_empty():
				free_parent()
				var new_position = colliding_foundations[0].global_position
				in_depot = false
				in_foundation = true
				check_moved_from_waste()
				global_position = new_position
			else:
				global_position = pre_drag_position
		
	last_mouse_position = current_mouse_position
	
func flip() -> void:
	face_up = !face_up
	front_sprite.visible = face_up
	value_label.visible = face_up
	suit_label.visible = face_up
	back_sprite.visible = !face_up
	
func trigger_dragging() -> bool:
	return has_mouse \
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
		and !dragging_blocked\
		and !Globals.dragging_card
		
func can_pile_in_depot(card: Node2D) -> bool:
	return card.value == value + 1 and (card.suit == (suit + 1) % 4 or card.suit == (suit + 3) % 4)
	
func can_pile_in_foundation(card: Node2D) -> bool:
	return child_card == null and card.value == value - 1 and card.suit == suit

func toggle_being_dragged() -> void:
	being_dragged = !being_dragged
	Globals.dragging_card = being_dragged
	if being_dragged:
		z_index += 1000
		scale = Vector2(1.2, 1.2)
		pre_drag_position = global_position
	else:
		z_index -= 1000
		scale = Vector2(1, 1)
	if child_card != null:
		child_card.toggle_being_dragged()
		
func free_parent():
	if parent_card != null:
		parent_card.child_card = null
		parent_card.dragging_blocked = false
		if !parent_card.face_up:
			parent_card.flip()
		parent_card = null
		
func check_moved_from_waste() -> void:
	if "FirstCard" in get_parent().name:
		var cards = get_tree().root.get_node("Klondike/Cards")
		get_parent().get_parent().remove_card(self)
		cards.add_child(self)

func _on_area_2d_mouse_entered() -> void:
	has_mouse = true

func _on_area_2d_mouse_exited() -> void:
	has_mouse = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if !being_dragged: return
	var parent = area.get_parent()
	if "Card" in parent.name and !parent.being_dragged and parent.face_up and (parent.in_depot or parent.in_foundation):
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
