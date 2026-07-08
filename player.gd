extends Node2D

@export var slot_markers: Array[Marker2D] = []
@export var slot_areas: Array[Area2D] = []
@export var silhouette: Sprite2D

func _ready():
	global_position = slot_markers[GameState.player_slot_index].global_position
	for area in slot_areas:
		area.slot_clicked.connect(move_to_slot)
		area.slot_hovered.connect(_on_slot_hovered)

func move_to_slot(index: int):
	GameState.player_slot_index = index
	global_position = slot_markers[index].global_position
	silhouette.hide_silhouette()

func _on_slot_hovered(index: int, is_hovering: bool):
	if index == GameState.player_slot_index:
		return
	if is_hovering:
		silhouette.show_at(slot_markers[index].global_position)
	else:
		silhouette.hide_silhouette()
