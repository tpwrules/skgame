# from https://docs.godotengine.org/en/3.1/tutorials/physics/using_kinematic_body_2d.html

extends Node2D

export (int) var run_speed = 400
export (int) var jump_speed = -400
export (int) var gravity = 1200

var jumping = false

# the skateboard has two wheels. we treat the front wheel as the leader.
# it moves around and collides and whatever. the back wheel is mostly
# independent, but is constrained to be a fixed distance
# from the front wheel. this lets the skateboard tilt on slopes. note
# that the front wheel will drag the skateboard over the edge, while the
# back wheel will not.

# the velocity of the wheels
var f_vel = Vector2()
var b_vel = Vector2()
# and their game objects
onready var f_wheel = $"front_wheel"
onready var b_wheel = $"back_wheel"

onready var gfx_obj = $"graphics"
onready var gfx_anim = $"tricks"

# the graphics follow the leading wheel and rotate around it
onready var gfx_pos = f_wheel.global_position - gfx_obj.global_position
# the wheels are a fixed distance apart
onready var wheel_dist = (f_wheel.global_position-b_wheel.global_position).length()

var grinding = false

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	var grind = Input.is_action_just_pressed('g_grind')
	var do_frontflip = Input.is_action_just_pressed("g_frontflip")
	var do_backflip = Input.is_action_just_pressed("g_backflip")

	f_vel.x = 0
	b_vel.x = 0
	if jump and f_wheel.is_on_floor():
		jumping = true
		f_vel.y = jump_speed
		b_vel.y = jump_speed
	if right:
		f_vel.x += run_speed
		b_vel.x += run_speed
	if left:
		f_vel.x -= run_speed
		b_vel.x -= run_speed
	if grind:
		if grinding:
			gfx_anim.play("grind_stop")
		else:
			gfx_anim.play("grind_start")
		grinding = not grinding
	elif do_frontflip:
		gfx_anim.play("frontflip")
	elif do_backflip:
		gfx_anim.play("backflip")

func _physics_process(delta):
	get_input()

	# physicate the two wheels independently
	f_vel.y += gravity * delta
	b_vel.y += gravity * delta
	if jumping and f_wheel.is_on_floor():
		jumping = false
	f_vel = f_wheel.move_and_slide(f_vel, Vector2(0, -1))
	b_vel = b_wheel.move_and_slide(b_vel, Vector2(0, -1))
	
	var f_pos = f_wheel.global_position
	
	# make the graphics follow the wheels
	gfx_obj.global_position = f_pos - gfx_pos
	
	# force the back wheel to a fixed distance from the front wheel.
	# we still want it to be in the same direction relative to the front.
	var back_wheel_dir = f_pos.direction_to(b_wheel.global_position)
	# but with the fixed distance.
	var b_pos = (back_wheel_dir*wheel_dist)+f_pos
	b_wheel.global_position = b_pos
	
	# rotate the graphics so the skateboard sits on its wheels.
	gfx_obj.rotation = (f_pos-b_pos).angle()
