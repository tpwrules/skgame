extends Position2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var spraycan = $"spraycan"
onready var spray_rel_pos = self.position # us relative to our parent
var tex_on = false
var tex_off = false

var was_spraying = false

# list of available stamp textures
var stamp_texs = []
# node where we stuff all the stamps that got put out
onready var stamp_objects = $"../../../stamp_objects"
# randomly select stamp to draw
onready var rng = RandomNumberGenerator.new()

func _ready():
	# load the on state and off state textures so we can swap them as necessary
	tex_on = ImageTexture.new()
	var img_on = Image.new()
	img_on.load("res://player/spraycan_on.png")
	tex_on.create_from_image(img_on, 0) # mipmaps make it look blurry
	
	tex_off = ImageTexture.new()
	var img_off = Image.new()
	img_off.load("res://player/spraycan_off.png")
	tex_off.create_from_image(img_off, 0)
	
	was_spraying = true
	self.set_spraying(false) # make sure correct state is shown
	
	# load all the stamps so we can draw a random one when asked
	var stamp_dir = Directory.new()
	stamp_dir.open("res://player/spray_stamps")
	stamp_dir.list_dir_begin(true, true)
	while true:
		var fname = stamp_dir.get_next()
		if fname == "": break
		if not fname.ends_with(".png"): continue
		# fname is a png that we want to texturize as above
		var tex = ImageTexture.new()
		var img = Image.new()
		if img.load("res://player/spray_stamps/"+fname) == 0:
			# make sure image loaded successfully
			tex.create_from_image(img, 0)
			stamp_texs.append(tex)
	stamp_dir.list_dir_end()

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
	
	var spray_pos = self.get_parent().global_position+spray_rel_pos
	
	# figure out how far the mouse is away from us
	var mouse_dist = (spray_pos-mouse_pos).length()
	# and figure out in which direction
	var mouse_dir = (mouse_pos-spray_pos).normalized()
	if mouse_dist > 200:
		mouse_dist = 0.01
		mouse_dir = Vector2(1, 0)
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
