extends Node2D

enum State { THROWN, STUCK_ALIVE, STUCK_DEAD, ON_GROUND }
var state: State = State.THROWN

var start_pos: Vector2
var target_pos: Vector2
var travel_speed: float = 2000.0 # pixels/sec, tune later
var spin_speed: float = 20.0 # radians/sec, tune later
var retrieval_time: float = 1.0
var retrieval_progress: float = 0.0
var is_retrieving: bool = false
var nearest_column: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var progress_ring: TextureProgressBar = $ProgressRing
@onready var collision_area: Area2D = $CollisionArea
@export var sprite_angle_offset_degrees: float = 0.0

func _ready():
	sprite.material = sprite.material.duplicate()
	sprite.material.set_shader_parameter("sprite_scale", sprite.scale)
	progress_ring.visible = false
	progress_ring.value = 0
	collision_area.input_pickable = true
	collision_area.mouse_entered.connect(func(): sprite.material.set_shader_parameter("show_outline", true))
	collision_area.mouse_exited.connect(func(): sprite.material.set_shader_parameter("show_outline", false))
	collision_area.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_retrieval(GameState.player_slot_index)
		else:
			cancel_retrieval()
	elif event is InputEventScreenTouch:
		if event.pressed:
			start_retrieval(GameState.player_slot_index)
		else:
			cancel_retrieval()
	
func _process(delta):
	if state == State.THROWN:
		global_position = global_position.move_toward(target_pos, travel_speed * delta)
		if global_position.distance_to(target_pos) < 1.0:
			_on_reached_target()

	if is_retrieving:
		retrieval_progress += delta
		progress_ring.value = (retrieval_progress / retrieval_time) * 100.0
		if retrieval_progress >= retrieval_time:
			_complete_retrieval()

func launch(from: Vector2, to: Vector2, wall_y_value: float):
	start_pos = from
	var clamped_to = _clamp_to_wall(from, to, wall_y_value)
	target_pos = clamped_to
	global_position = from
	state = State.THROWN
	
	var direction = (target_pos - from).normalized()
	sprite.rotation = direction.angle() + deg_to_rad(sprite_angle_offset_degrees)
	
func _on_reached_target():
	state = State.STUCK_ALIVE
	var bounce_pos = target_pos.lerp(start_pos, 0.35) # or your 200px version, whichever you kept

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", bounce_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var spin_tween = create_tween()
	spin_tween.tween_property(sprite, "rotation", sprite.rotation + spin_speed * 0.7, 0.1).set_trans(Tween.TRANS_LINEAR)
	spin_tween.tween_property(sprite, "rotation", sprite.rotation + spin_speed, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_callback(func():
		state = State.ON_GROUND
		nearest_column = _find_nearest_column(global_position)
	)

func _find_nearest_column(pos: Vector2) -> int:
	var closest_index = 0
	var closest_dist = INF
	for i in GameState.slot_positions.size():
		var dist = abs(pos.x - GameState.slot_positions[i].x)
		if dist < closest_dist:
			closest_dist = dist
			closest_index = i
	return closest_index
	
func _clamp_to_wall(from: Vector2, to: Vector2, wall_y_value: float) -> Vector2:
	var direction = (to - from).normalized()
	var distance_to_wall = (wall_y_value - from.y) / direction.y
	return from + direction * distance_to_wall
	
#====================================================================================================================
#Retrieval
#=====================================================================================================================

func start_retrieval(player_column: int):
	if state != State.ON_GROUND and state != State.STUCK_DEAD:
		return
	is_retrieving = true
	GameState.is_retrieving_knife = true
	retrieval_progress = 0.0
	progress_ring.visible = true
	retrieval_time = _get_retrieval_time(player_column, nearest_column)

func cancel_retrieval():
	if not is_retrieving:
		return
	is_retrieving = false
	GameState.is_retrieving_knife = false
	retrieval_progress = 0.0
	progress_ring.visible = false
	progress_ring.value = 0

func _complete_retrieval():
	is_retrieving = false
	GameState.knife_count += 1
	GameState.suppress_next_throw = true
	queue_free()

func _get_retrieval_time(player_col: int, knife_col: int) -> float:
	var diff = abs(player_col - knife_col)
	if diff == 0: return 0.5
	elif diff == 1: return 1.0
	else: return 1.5
