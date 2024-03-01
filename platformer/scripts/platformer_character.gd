class_name PlatformerCharacter
extends CharacterBody2D

enum JumpType {
	JUMP_SET,
	JUMP_ADD,
	JUMP_COMBINED
}

@export_category("Movement")
@export_group("Idle", "idle")
@export var idle_deceleration: float = 900.
@export var idle_landing_deceleration: float = 200.

@export_group("Move", "move")
@export var move_speed = 300.0
@export var move_deceleration: float = 1200.
@export var move_acceleration: float = 600.
@export var move_slowdown: float = 200.
@export var move_landing_deceleration: float = 300.

@export_group("Air", "air")
@export_subgroup("Vertical", "air")
@export var air_max_fall_speed: float = 2400.
@export var air_up_gravity: float = 2400.
@export var air_down_gravity: float = 1200.
@export_subgroup("Horisontal", "air")
@export var air_max_speed: float = 500.0
@export var air_deceleration: float = 150.
@export var air_acceleration: float = 100.
@export var air_slowdown: float = 200.

@export_group("Jump", "jump")
@export var jump_type: JumpType = JumpType.JUMP_COMBINED
@export var jump_velocity: float = -500.0
@export var jump_up_gravity: float = 900.
@export var jump_coyote_time: float = 0.2
@export var jump_buffer_time: float = 0.2

var last_ground_touch_time: int = 0
var last_jump_pressed_time: int = 0

@onready var state_chart: StateChart = $StateChart


func _process_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		last_jump_pressed_time = Time.get_ticks_msec()
	if float(Time.get_ticks_msec() - last_jump_pressed_time) / 1000.0 < jump_buffer_time\
			and float(Time.get_ticks_msec() - last_ground_touch_time) / 1000.0 < jump_coyote_time:
		match jump_type:
			JumpType.JUMP_SET:
				velocity.y = jump_velocity
			JumpType.JUMP_ADD:
				velocity.y += jump_velocity
			JumpType.JUMP_COMBINED:
				velocity.y = max(jump_velocity + velocity.y, jump_velocity)
		last_ground_touch_time = 0
		last_jump_pressed_time = 0


#region Move state
func _on_ground_state_physics_processing(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if not is_on_floor():
		state_chart.send_event("fall")
	else:
		last_ground_touch_time = Time.get_ticks_msec()
	if direction:
		if not sign(velocity.x) or sign(direction) == sign(velocity.x):
			var desired_speed: float = abs(move_speed * direction)
			if abs(velocity.x) < desired_speed:
				velocity.x = min(
						abs(velocity.x) + move_acceleration * delta,
						desired_speed
						) * sign(direction)
			elif abs(velocity.x) > desired_speed:
				velocity.x = max(
						abs(velocity.x) - move_slowdown * delta,
						desired_speed
						) * sign(direction)
		else:
			velocity.x = max(
					abs(velocity.x) - move_deceleration * delta,
					0
					) * sign(velocity.x)
	elif velocity.x:
		velocity.x = max(0, abs(velocity.x) - idle_deceleration * delta) * sign(velocity.x)
	_process_jump()
	move_and_slide()




func _on_landing_taken() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if not direction:
		velocity.x = max(0, abs(velocity.x) - idle_landing_deceleration) * sign(velocity.x)
	elif sign(direction) != sign(velocity.x):
		velocity.x = max(0, abs(velocity.x) - move_landing_deceleration) * sign(velocity.x)
#endregion


#region Air
func _on_air_state_physics_processing(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if is_on_floor():
		state_chart.send_event("landing")
	if direction:
		if not sign(velocity.x) or sign(direction) == sign(velocity.x):
			var desired_speed: float = abs(air_max_speed * direction)
			if abs(velocity.x) < desired_speed:
				velocity.x = min(
						abs(velocity.x) + air_acceleration * delta,
						desired_speed
					) * sign(direction)
			elif abs(velocity.x) > desired_speed:
				velocity.x = max(
						abs(velocity.x) - air_slowdown * delta,
						desired_speed
					) * sign(direction)
		else:
			velocity.x = max(
					abs(velocity.x) - air_deceleration * delta,
					0
				) * sign(velocity.x)
	if velocity.y >= 0:
		velocity.y += air_down_gravity * delta
	else:
		if Input.is_action_pressed("jump"):
			velocity.y = min(0, velocity.y + jump_up_gravity * delta)
		else:
			velocity.y = min(0, velocity.y + air_up_gravity * delta)
	_process_jump()
	move_and_slide()
#endregion
