extends CharacterBody3D


@export var SPEED_WALK := 10.0
@export var SPEED_SPRINT := 32.0 # Debugging moment
@export var SENSITIVITY := 0.1
@export var HOLD_LERP_SPEED := 8
@export var HOLD_THROW_SPEED := 8

@export var FOOTSTEP_MIN_WAIT_TIME := 0.1
@export var FOOTSTEP_MAX_WAIT_TIME := 0.2
@export var AUDIO_RAND_MIN_PITCH_SCALE := 0.9
@export var AUDIO_RAND_MAX_PITCH_SCALE := 1.1

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var footstep_active := false
var RNG := RandomNumberGenerator.new()


func reset() -> void:
	%Camera.current = true
	%RotationHelper.rotation_degrees.x = 0


func get_input_direction() -> Vector2:
	return Input.get_vector("mv_left", "mv_right", "mv_fwd", "mv_back")


func set_ui_visible(vis: bool) -> void:
	for child in get_children():
		if child is Control:
			child.visible = vis


func hide_ui() -> void:
	set_ui_visible(false)


func show_ui() -> void:
	set_ui_visible(true)


func _process(_delta: float) -> void:
	var input_dir := get_input_direction()
	if not footstep_active and (input_dir.x != 0.0 or input_dir.y != 0.0) and %Camera.current:
		footstep_active = true
		$Footstep/FootstepTimer.start(RNG.randf_range(FOOTSTEP_MIN_WAIT_TIME, FOOTSTEP_MAX_WAIT_TIME))


func _physics_process(delta: float) -> void:
	var speed := SPEED_SPRINT if Globals.DEBUG_OPTS["can_sprint"] and Input.is_action_pressed("mv_sprint") else SPEED_WALK	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := get_input_direction()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		var smoothing := pow(speed, 2) * delta;
		velocity.x = move_toward(velocity.x, 0, smoothing)
		velocity.z = move_toward(velocity.z, 0, smoothing)
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var x_rotation: float = event.relative.y * SENSITIVITY
		if not Globals.invert_y:
			x_rotation *= -1
		%RotationHelper.rotate_x(deg_to_rad(x_rotation))
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		var camera_rot: Vector3 = %RotationHelper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -90, 90)
		%RotationHelper.rotation_degrees = camera_rot
	
	elif event.is_action_pressed("interact"):
		var interactible: Object = %InteractRay.get_collider()
		if interactible and interactible is InteractNode3D:
			interactible._on_interacted_with()


func _on_footstep_timer_timeout():
	$Footstep.pitch_scale = RNG.randf_range(AUDIO_RAND_MIN_PITCH_SCALE, AUDIO_RAND_MAX_PITCH_SCALE)
	$Footstep.play()


func _on_footstep_finished():
	footstep_active = false
