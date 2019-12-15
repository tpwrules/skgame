extends Position2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var spraycan = $"spraycan"
onready var spray_rel_pos = self.position # us relative to our parent
onready var tex_on = load("player/spraycan_on.png")
onready var tex_off = load("res://player/spraycan_off.png")

# list of available stamp textures
onready var stamp_texs = [
	load("res://player/spray_stamps/coebalt.png"),
	load("res://player/spray_stamps/zhee.png"),
	load("res://player/spray_stamps/tpw_rules.png"),
]

var was_spraying = false

# node where we stuff all the stamps that got put out
onready var stamp_objects = $"../../../stamp_objects"
# randomly select stamp to draw
onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	rng.seed += 420 # different stream from others
	# make sure correct spray state is shown
	was_spraying = true
	self.set_spraying(false)

func set_spraying(spraying):
	if spraying != was_spraying:
		if spraying == true:
			spraycan.set_texture(tex_on)
		else:
			spraycan.set_texture(tex_off)
		was_spraying = spraying
		
func _physics_process(delta):
	# aim the spraycan at the mouse
	var mouse_pos = get_global_mouse_position()
	
	var spray_pos = self.get_parent().global_position
	
	# figure out how far the mouse is away from us
	var mouse_dist = (spray_pos-mouse_pos).length()
	# and figure out in which direction
	var mouse_dir = (mouse_pos-spray_pos).normalized()
	if mouse_dist > 250:
		self.global_position = spray_pos+spray_rel_pos
		self.global_rotation = 0
	else:
		# now point us at that spot
		self.global_position = spray_pos+(mouse_dist*mouse_dir)
		self.global_rotation = mouse_dir.angle()
		
	# should we create a stamp here?
	if not Input.is_action_just_pressed("g_stamp"): return
	
	# apparently. make a new sprite to hold it
	var stamp_spr = Sprite.new()
	# pick a random stamp to display
	var stamp_tex = stamp_texs[rng.randi_range(0, len(stamp_texs)-1)]
	stamp_spr.set_texture(stamp_tex)
	stamp_objects.add_child(stamp_spr)
	# scale the stamp to be not too wide
	var STAMP_WIDTH = 100
	var tex_size = stamp_tex.get_size()
	var scale = tex_size.x/STAMP_WIDTH
	stamp_spr.scale = Vector2(1/scale, 1/scale)
	stamp_spr.global_position = self.global_position - (tex_size/scale)/2
