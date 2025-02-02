extends Node2D

@onready var cards_parent: Node2D = $CardsParent

func _ready() -> void:
	var x = 0
	var y = 0
	for i in range(cards_parent.get_child_count()):
		if i > 0:
			if i % 13 == 0:
				x = 0
				y += 1
			else:
				x += 1
		var card = cards_parent.get_children()[i]
		card.position.x = 75 * x
		card.position.y = 100 * y
		if (randi()%2==1):
			card.flip()

func _process(_delta: float) -> void:
	pass
