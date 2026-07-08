extends Node

@export var slot_markers: Array[Marker2D] = []

func _ready():
	for marker in slot_markers:
		GameState.slot_positions.append(marker.global_position)
