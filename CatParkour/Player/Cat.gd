extends KinematicBody

var speed = pStats.movement
var acceleration = pStats.accel
var air_acceleration = pStats.air_accel
var gravity = pStats.gravity
var max_terminal_velocity = 54
var jump_power = pStats.jump_power

var mouse_sensitivity = pStats.sens
var min_pitch = -90
var max_pitch = 90

var velocity : Vector3
var y_velocity : float

onready var camera_pivot = $camerapivot
onready var camera = $camerapivot/SpringArm/Camera
onready var DashLength = $camerapivot/SpringArm/Camera/DashSprite
onready var Bullet_Scene = preload("res://Bullet.tscn")


var dash_speed = 4
var dash
var dashtime = 0
var dashCD = 1.5
var dashable = true

var DistanceSprite

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	DistanceSprite = $camerapivot/SpringArm/Camera/DashSprite.global_transform.origin - global_transform.origin

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_pitch, max_pitch)

func _physics_process(delta):
	_handle_movement(delta)
#
func _handle_movement(delta):
	var direction = Vector3()
	
	if Input.is_action_pressed("shoot"):
		var bullet = Bullet_Scene.instance()
		get_parent().add_child(bullet)
		bullet.global_transform.origin = $gun.global_transform.origin
		bullet.look_at(DistanceSprite, Vector3.UP)
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if Input.is_action_just_pressed("dash") and dashable == true:
#		var original = global_transform.origin
##		direction += (DashLength.global_transform.origin - global_transform.origin).normalized()
#		global_transform.origin = lerp(global_transform.origin, DashLength.global_transform.origin, .1)
#		print()
#		print("original position" + str(original))
#		print("new position " + str(global_transform.origin))
		dash = (DashLength.global_transform.origin - global_transform.origin).normalized() * dash_speed
	if dash != null:
		dashtime += delta
		$DashPart.set_emitting(true)
		if DistanceSprite != null:
			$DashPart.process_material.gravity = DistanceSprite
		if dashtime >= .3:
			dashtime = 0
			dash = null
			dashable = false
			$DashPart.process_material.gravity = Vector3.ZERO
	if dashable == false:
		$DashPart.set_emitting(false)
		dashCD -= delta
		if dashCD <= 0:
			dashable = true
			dashCD = 1.5
	
	direction = direction.normalized()
	
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	if dash!= null:
		velocity += dash
	
	if is_on_floor():
		y_velocity = -.01
	else:
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_velocity = jump_power
	velocity.y = y_velocity
	velocity = move_and_slide(velocity, Vector3.UP)
