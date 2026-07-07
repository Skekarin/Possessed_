extends Node2D

@export var slot_areas: Array[Area2D] = []
signal throw_requested(target_position: Vector2)

func _is_over_slot(pos: Vector2) -> bool:
	for area in slot_areas:
		if area.get_node("CollisionShape2D").shape.get_rect().has_point(area.to_local(pos)):
			return true
	return false

func _unhandled_input(event):
	if event is InputEventMouseMotion or event is InputEventScreenTouch or event is InputEventScreenDrag:
		var pos = get_global_mouse_position()
		if not _is_over_slot(pos):
			global_position = pos

	var is_release = (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) \
		or (event is InputEventScreenTouch and not event.pressed)
	if is_release and not _is_over_slot(get_global_mouse_position()):
		throw_requested.emit(global_position)
