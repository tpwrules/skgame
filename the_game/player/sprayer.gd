extends Position2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var spraycan = $"../spraycan"
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
