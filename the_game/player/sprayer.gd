extends Position2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var spraycan = $"spraycan"
onready var spray_rel_pos = self.position # us relative to our parent
var tex_on = false
var tex_off = false

var was_spraying = false

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
