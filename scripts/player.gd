extends CharacterBody3D

@onready var camera_mount: Node3D = $cameraMount
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $visuals

var SPEED = 3.0
const JUMP_VELOCITY = 4.5

var walkSpeed = 3.0
var runSpeed = 5.0

var running := false

var locked = false

@export var hSense = 0.18
@export var ySense = 0.15

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * hSense))
		visuals.rotate_y(deg_to_rad(event.relative.x * hSense))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * ySense))

func _physics_process(delta: float) -> void:

	if !animation_player.is_playing():
		locked = false

	if Input.is_action_just_pressed("kick") and is_on_floor():
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			locked = true

	if Input.is_action_pressed("run"):
		SPEED = runSpeed
		running = true
	else:
		SPEED = walkSpeed
		running = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !locked:
			if running: 
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")

			visuals.look_at(position + direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !locked:
		move_and_slide()
