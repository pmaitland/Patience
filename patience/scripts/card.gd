extends Node2D

@onready var front: Node2D = $Front
@onready var back: Node2D = $Back

var value: Enums.Value
var suit: Enums.Suit

var face_up: bool = true
var has_outline: bool = false

var full_area_has_mouse: bool = false
var small_area_has_mouse: bool = false
var dragging_blocked: bool = false
var being_dragged: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

var returning_to_pre_drag_position: bool = false
var pre_drag_position: Vector2 = global_position
var post_drag_position: Vector2 = global_position

var in_depot: bool = false
var in_foundation: bool = false

var colliding_cards: Array[Node2D] = []
var colliding_foundations: Array[Node2D] = []
var colliding_depots: Array[Node2D] = []

var parent_card: Node2D = null
var child_card: Node2D = null

var t: float = 0.0
var delta_mult: float = 2.0

func _process(_delta: float) -> void:
	var current_mouse_position: Vector2 = get_global_mouse_position()
	
	if parent_card != null and !being_dragged and !returning_to_pre_drag_position:
		z_index = parent_card.z_index + 1
		global_position = Vector2(parent_card.global_position.x, parent_card.global_position.y)
		if !parent_card.in_foundation:
			global_position.y += 40
			
	has_outline = (full_area_has_mouse and "Stock" in get_parent().get_parent().name) or \
		(face_up and !dragging_blocked and \
			(being_dragged \
			or (parent_card != null and parent_card.has_outline) \
			or small_area_has_mouse \
			or (full_area_has_mouse and child_card == null)))
	if has_outline:
		front.get_child(0).material.set_shader_parameter('width', 3)
	else:
		front.get_child(0).material.set_shader_parameter('width', 0)
	
	if trigger_dragging():
		delta_mult = 10.0
		toggle_being_dragged()
		
	if being_dragged:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position.x += current_mouse_position.x - last_mouse_position.x
			global_position.y += current_mouse_position.y - last_mouse_position.y
		else:
			toggle_being_dragged()
			if !colliding_cards.is_empty():
				var moved: bool = false
				for card: Node2D in colliding_cards:
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
					post_drag_position = global_position
					t = 0.0
					returning_to_pre_drag_position = true
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
				post_drag_position = global_position
				t = 0.0
				returning_to_pre_drag_position = true
		
	last_mouse_position = current_mouse_position
	
func _physics_process(delta: float) -> void:
	if returning_to_pre_drag_position:
		t += delta * delta_mult
		if z_index < 1000:
			z_index += 1000
		global_position = post_drag_position.lerp(pre_drag_position, t)
		if global_position == pre_drag_position:
			returning_to_pre_drag_position = false
			z_index -= 1000
		
func setup(v: Enums.Value, s: Enums.Suit) -> void:
	value = v
	suit = s
	name = "Card%s-%s" % [value, suit]
	
	var color: Color = Colors.CARD_BLACK
	if is_red():
		color = Colors.CARD_RED
	
	var cornerValueSprite: Texture2D = load("res://sprites/card/corner/value/{value}.png".format({
		"value": Enums.Value.keys()[value]
	}))
	front.get_child(1).texture = cornerValueSprite
	front.get_child(2).texture = cornerValueSprite
	
	var cornerSuitSprite: Texture2D = load("res://sprites/card/corner/suit/{suit}.png".format({
		"suit": Enums.Suit.keys()[suit]
	}))
	front.get_child(3).texture = cornerSuitSprite
	front.get_child(4).texture = cornerSuitSprite
	
	if value == Enums.Value.ACE:
		var aceSprite: Texture2D = load("res://sprites/card/centre/ace/{suit}.png".format({
			"suit": Enums.Suit.keys()[suit]
		}))
		front.get_child(5).texture = aceSprite
		front.get_child(5).visible = true
	
	for i in range(1, front.get_child_count()):
		front.get_child(i).set_modulate(color)
		
	back.get_child(1).set_modulate(Colors.CARD_BACK)
	
	front.get_child(0).material.set_shader_parameter('color', Colors.CARD_OUTLINE)
	
	dragging_blocked = true
	
func is_black() -> bool:
	return suit == Enums.Suit.SPADES or suit == Enums.Suit.CLUBS

func is_red() -> bool:
	return suit == Enums.Suit.HEARTS or suit == Enums.Suit.DIAMONDS

func flip() -> void:
	face_up = !face_up
	front.visible = face_up
	back.visible = !face_up
	
func trigger_dragging() -> bool:
	return (small_area_has_mouse or (full_area_has_mouse and child_card == null)) \
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
		and !dragging_blocked \
		and !returning_to_pre_drag_position \
		and !Globals.dragging_card
		
func can_pile_in_depot(card: Node2D) -> bool:
	return card.in_depot and card.value == value + 1 and (card.suit == (suit + 1) % 4 or card.suit == (suit + 3) % 4)
	
func can_pile_in_foundation(card: Node2D) -> bool:
	return card.in_foundation and child_card == null and card.value == value - 1 and card.suit == suit

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
		var cards: Node2D = get_tree().root.get_node("Klondike/Cards")
		get_parent().get_parent().remove_card(self)
		cards.add_child(self)

func _on_full_area_mouse_entered() -> void:
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		full_area_has_mouse = true

func _on_full_area_mouse_exited() -> void:
		full_area_has_mouse = false
	
func _on_small_area_mouse_entered() -> void:
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		small_area_has_mouse = true

func _on_small_area_mouse_exited() -> void:
		small_area_has_mouse = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if !being_dragged: return
	var parent: Node2D = area.get_parent()
	if "Card" in parent.name and !parent.being_dragged and parent.face_up and (parent.in_depot or parent.in_foundation):
		colliding_cards.append(parent)
	elif "Foundation" in parent.name and value == Enums.Value.ACE:
		colliding_foundations.append(parent)
	elif "Depot" in parent.name and value == Enums.Value.KING:
		colliding_depots.append(parent)

func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent: Node2D = area.get_parent()
	if parent in colliding_cards:
		colliding_cards.remove_at(colliding_cards.find(parent))
	elif parent in colliding_foundations:
		colliding_foundations.remove_at(colliding_foundations.find(parent))
	elif parent in colliding_depots:
		colliding_depots.remove_at(colliding_depots.find(parent))
