extends Node

@export var reticle: Node2D
@export var player: Node2D
@export var knife_scene: PackedScene

func _ready():
	reticle.throw_requested.connect(_on_throw_requested)

func _on_throw_requested(target_position: Vector2):
	if GameState.knife_count <= 0:
		return
	GameState.knife_count -= 1
	var knife = knife_scene.instantiate()
	get_tree().current_scene.add_child(knife)
	knife.launch(player.global_position, target_position)
