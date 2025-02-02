extends Node2D

@onready var value_label: Label = $ValueLabel
@onready var suit_label: Label = $SuitLabel
@onready var front_sprite: Sprite2D = $FrontSprite
@onready var back_sprite: Sprite2D = $BackSprite

@export var value: Enums.Value
@export var suit: Enums.Suit

var face_up: bool = true

var last_mouse_position: Vector2 = Vector2.ZERO
var has_mouse: bool = false
var being_dragged: bool = false

func _ready() -> void:
	value_label.text = str(value)
	suit_label.text = str(suit)

func _process(_delta: float) -> void:
	var current_mouse_position = get_global_mouse_position()
	
	if has_mouse and !Globals.mouse_has_card and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		being_dragged = true
		scale = Vector2(1.2, 1.2)
		Globals.mouse_has_card = true
	
	if being_dragged:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position.x += current_mouse_position.x - last_mouse_position.x
			global_position.y += current_mouse_position.y - last_mouse_position.y
		else:
			being_dragged = false
			scale = Vector2(1, 1)
			Globals.mouse_has_card = false
		
	last_mouse_position = current_mouse_position
	
func flip() -> void:
	face_up = !face_up
	if face_up:
		front_sprite.visible = true
		value_label.visible = true
		suit_label.visible = true
		back_sprite.visible = false
	else:
		front_sprite.visible = false
		value_label.visible = false
		suit_label.visible = false
		back_sprite.visible = true

func _on_area_2d_mouse_entered() -> void:
	has_mouse = true

func _on_area_2d_mouse_exited() -> void:
	has_mouse = false
