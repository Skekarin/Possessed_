extends Area2D

@export var slot_index: int
signal slot_clicked(index: int)
signal slot_hovered(index: int, is_hovering: bool)

func _ready():
		input_pickable = true
		mouse_entered.connect(func(): slot_hovered.emit(slot_index, true))
		mouse_exited.connect(func(): slot_hovered.emit(slot_index, false))
		input_event.connect(_on_input_event)
					
func _on_input_event(_viewport, event, _shape_idx):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(slot_index)
