extends Sprite2D

func show_at(marker_pos: Vector2):
	global_position = marker_pos
	visible = true

func hide_silhouette():
	visible = false
