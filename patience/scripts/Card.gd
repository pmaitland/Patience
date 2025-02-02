extends Node2D

@onready var value_label: Label = $ValueLabel
@onready var suit_label: Label = $SuitLabel
@onready var front_sprite: Sprite2D = $FrontSprite
@onready var back_sprite: Sprite2D = $BackSprite

@export var value: Enums.Value
@export var suit: Enums.Suit

var face_up: bool = true

var has_mouse: bool = false

func _ready() -> void:
	value_label.text = str(value)
	suit_label.text = str(suit)

func _process(_delta: float) -> void:
	pass
	
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
