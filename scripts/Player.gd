extends CharacterBody3D

# Player movement code is modified from https://aneacsu.com/blog/2023/04/09/quake-movement-godot
# Constants have also been tweaked for better movement (in my opinion)

const MAX_VEL_AIR := 0.6
const MAX_VEL_GROUND := 6.0
const MAX_ACCEL := 10 * MAX_VEL_GROUND
const FRICTION := 9
const STOP_SPEED := 1.5
const WALK_MULTIPLIER := 0.85

const HOLD_LERP_SPEED := 10

const FOOTSTEP_MIN_WAIT_TIME := 0.1
const FOOTSTEP_MAX_WAIT_TIME := 0.2
const FOOTSTEP_MIN_WAIT_TIME_WALK := 0.3
const FOOTSTEP_MAX_WAIT_TIME_WALK := 0.4
const AUDIO_RAND_MIN_PITCH_SCALE := 0.9
const AUDIO_RAND_MAX_PITCH_SCALE := 1.1

const JOY_DEADZONE := 0.2
const JOY_AXIS_SCALE := 1.0 / (1.0 - JOY_DEADZONE)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_force = sqrt(gravity * 6)
var is_jump_requested := false
var is_walking := false

var footstep_active := false
var RNG := RandomNumberGenerator.new()

var held: RigidBody3D = null
var held_parent: Node = null


func held_is_valid() -> bool:
	return held and is_instance_valid(held)


func reset() -> void:
	%Camera.current = true
	rotation_degrees.y = 0
	%RotationHelper.rotation_degrees.x = 0


func set_ui_visible(vis: bool) -> void:
	for child in get_children():
		if child is Control:
			child.visible = vis


func hide_ui() -> void:
	set_ui_visible(false)


func show_ui() -> void:
	set_ui_visible(true)


func collect_inputs() -> Vector3:
	is_jump_requested = Globals.GLOBAL_OPTS["player_can_jump"] && Input.is_action_just_pressed("mv_jump")
	is_walking = Input.is_action_pressed("mv_walk")
	
	var input_dir := Input.get_vector("mv_left", "mv_right", "mv_fwd", "mv_back")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func update_velocity(delta: float) -> void:
	var wish_dir := collect_inputs()
	if is_on_floor():
		if is_jump_requested:
			velocity.y = jump_force
			velocity = update_velocity_air(wish_dir, delta)
		else:
			if is_walking:
				velocity.x *= WALK_MULTIPLIER
				velocity.z *= WALK_MULTIPLIER
			velocity = update_velocity_ground(wish_dir, delta)
	else:
		velocity.y -= gravity * delta
		velocity = update_velocity_air(wish_dir, delta)


func accelerate(wish_dir: Vector3, max_speed: float, delta: float) -> Vector3:
	var current_speed = velocity.dot(wish_dir)
	return velocity + clamp(max_speed - current_speed, 0, MAX_ACCEL * delta) * wish_dir


func update_velocity_ground(wish_dir: Vector3, delta: float) -> Vector3:
	var speed = velocity.length()
	if speed != 0:
		var control = max(STOP_SPEED, speed)
		var drop = control * FRICTION * delta
		velocity *= max(speed - drop, 0) / speed
	return accelerate(wish_dir, MAX_VEL_GROUND, delta)


func update_velocity_air(wish_dir: Vector3, delta: float) -> Vector3:
	return accelerate(wish_dir, MAX_VEL_AIR, delta)


func _process(_delta: float) -> void:
	if not footstep_active and is_on_floor() and get_real_velocity().length() > 0.0 and %Camera.current:
		footstep_active = true
		if is_walking:
			$Footstep/FootstepTimer.start(RNG.randf_range(FOOTSTEP_MIN_WAIT_TIME_WALK, FOOTSTEP_MAX_WAIT_TIME_WALK))
		else:
			$Footstep/FootstepTimer.start(RNG.randf_range(FOOTSTEP_MIN_WAIT_TIME, FOOTSTEP_MAX_WAIT_TIME))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle movement
	update_velocity(delta)
	
	# Move held object
	if held_is_valid():
		var a: Vector3 = %PickupLerpPoint.get_global_transform().origin
		var b: Vector3 = held.get_global_transform().origin
		held.set_linear_velocity((a - b) * HOLD_LERP_SPEED)
		held.angular_damp = 2.0
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	var move_camera := func(motion: Vector2) -> void:
		if not Globals.invert_y:
			motion.x *= -1
		%RotationHelper.rotate_x(deg_to_rad(motion.x * Globals.mouse_sensitivity))
		rotate_y(deg_to_rad(motion.y * Globals.mouse_sensitivity))
		%RotationHelper.rotation_degrees.x = clamp(%RotationHelper.rotation_degrees.x, -90, 90)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		move_camera.call(Vector2(event.relative.y, -event.relative.x))
	elif event.is_action_pressed("interact"):
		if held and not held_is_valid():
			held = null
			held_parent = null
		
		if held_is_valid():
			# Put down object
			held.reparent(held_parent)
			held.set_linear_velocity(get_real_velocity() + held.linear_velocity)
			held.angular_damp = 0.0
			held._on_put_down()
			held = null
			held_parent = null
			return
		
		var interactible: Object = %InteractRay.get_collider()
		if not interactible:
			return
		
		if interactible is PickupNode3D:
			# Pick up object
			held = interactible
			held_parent = held.get_parent()
			held.reparent(%PickupLerpPoint)
			held._on_picked_up()
		elif interactible is InteractNode3D:
			# Interact with object
			interactible._on_interacted_with()


func _on_footstep_timer_timeout():
	$Footstep.pitch_scale = RNG.randf_range(AUDIO_RAND_MIN_PITCH_SCALE, AUDIO_RAND_MAX_PITCH_SCALE)
	$Footstep.play()


func _on_footstep_finished():
	footstep_active = false
