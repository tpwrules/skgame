# from https://docs.godotengine.org/en/3.1/tutorials/physics/using_kinematic_body_2d.html

extends Node2D

export (int) var run_speed = 600
export (int) var jump_speed = -900
export (int) var gravity = 1200

var jumping = false

var deck_vel = Vector2()
onready var deck_obj = $"deck"
onready var f_ray = $"deck/front_wheel"
onready var b_ray = $"deck/back_wheel"

onready var gfx_obj = $"graphics"
onready var gfx_anim = $"tricks"

# the graphics follow the leading wheel and rotate around it
onready var gfx_pos = deck_obj.position - gfx_obj.position

var grinding = false

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	var grind = Input.is_action_just_pressed('g_grind')
	var do_frontflip = Input.is_action_just_pressed("g_frontflip")
	var do_backflip = Input.is_action_just_pressed("g_backflip")

	deck_vel.x = 0
	if jump and not jumping:
		jumping = true
		deck_vel.y = jump_speed
	if right:
		deck_vel.x += run_speed
	if left:
		deck_vel.x -= run_speed
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
	
	# move the deck according to physics
	deck_vel.y += gravity * delta
	if jumping and deck_obj.is_on_floor():
		jumping = false
	deck_vel = deck_obj.move_and_slide(deck_vel, Vector2(0, -1))
	
	# try and level it out so both wheels touch the ground
	for x in range(10):
		# the rays check if the wheels can see ground. we updated
		# the deck's position above (and last loop) so we need to
		# measure again.
		f_ray.force_raycast_update()
		b_ray.force_raycast_update()
		
		# compute whether each ray hit something and, if so,
		# how far away it was
		var f_coll = f_ray.is_colliding()
		var f_dist = Vector2()
		var b_coll = b_ray.is_colliding()
		var b_dist = Vector2()
		if f_coll:
			f_dist = (f_ray.global_position-f_ray.get_collision_point()).length()
		else:
			f_dist = 100 # no collision, assume it hit at the ray's max length
		if b_coll:
			b_dist = (b_ray.global_position-b_ray.get_collision_point()).length()
		else:
			b_dist = 100 # no collision, assume it hit at the ray's max length
			
		# we consider the deck out of balance if the distance to the collision
		# between the two wheels is more than 5 pixels, and one of them is
		# already near something.
		var unlevel = abs(f_dist-b_dist) > 5 and (f_dist < 20 or b_dist < 20)
		
		# rotate the deck in a more level direction
		if not unlevel:
			break
		elif b_dist > f_dist:
			deck_obj.rotation_degrees -= 0.5
		elif f_dist > b_dist:
			deck_obj.rotation_degrees += 0.5
		
		# make sure it doesn't tip over completely
		var MAX_TILT = 65
		if abs(deck_obj.rotation_degrees) >= MAX_TILT:
			if deck_obj.rotation_degrees > 0:
				deck_obj.rotation_degrees = MAX_TILT
			else:
				deck_obj.rotation_degrees = -MAX_TILT
			break
	
	# position the graphics so the skateboard sits on its wheels.
	gfx_obj.position = deck_obj.position - gfx_pos
	gfx_obj.rotation = deck_obj.rotation

