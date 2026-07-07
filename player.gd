extends Node2D

@export var slot_markers: Array[Marker2D] = []
@export var slot_areas: Array[Area2D] = [] # same order: L, C, R
@export var silhouette: Sprite2D
var current_slot_index: int = 1

func _ready():
	global_position = slot_markers[current_slot_index].global_position
	for area in slot_areas:
		area.slot_clicked.connect(move_to_slot)
		area.slot_hovered.connect(_on_slot_hovered)

func move_to_slot(index: int):
	current_slot_index = index
	global_position = slot_markers[index].global_position
	silhouette.hide_silhouette()
	
func _on_slot_hovered(index: int, is_hovering: bool):
	if index == current_slot_index:
		return
	if is_hovering:
		silhouette.show_at(slot_markers[index].global_position)
	else:
		silhouette.hide_silhouette()
