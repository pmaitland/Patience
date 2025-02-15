extends Node2D

@onready var cards: Node2D = $Cards
@onready var waste: Node2D = $"../Waste"
@onready var outline_sprite: Sprite2D = $OutlineSprite

var has_mouse: bool = false
var draw_count: int = 3

func _ready() -> void:
	outline_sprite.material.set_shader_parameter('width', 3)
	outline_sprite.material.set_shader_parameter('color', Colors.CARD_OUTLINE)
	
func _input(event: InputEvent) -> void:
	if has_mouse and !Globals.dragging_card:
		outline_sprite.material.set_shader_parameter('width', 3)
		
		if event is InputEventMouseButton and event.is_pressed():
			if cards.get_child_count() == 0:
				waste.move_second_to_reserve()
				waste.move_first_to_second()
				waste.move_second_to_reserve()
				for card: Node2D in waste.reserve_cards.get_children():
					waste.reserve_cards.remove_child(card)
					cards.add_child(card)
					cards.move_child(card, 0)
					card.flip()
			else:
				for i: int in range(min(draw_count, cards.get_child_count())):
					var card: Node2D = cards.get_children()[cards.get_child_count()-1]
					cards.remove_child(card)
					waste.add_card(card)
	else:
		outline_sprite.material.set_shader_parameter('width', 0)

func _on_area_2d_mouse_entered() -> void:
	has_mouse = true

func _on_area_2d_mouse_exited() -> void:
	has_mouse = false
