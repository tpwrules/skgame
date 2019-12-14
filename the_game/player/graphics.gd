extends Node2D

# there is a strange bug in Godot where bones don't work right if
# the Z order is not zero. but we need the player's Z order to be
# higher than all other objects in the scene.

# it turns out we can fix this by rendering the player in a viewport
# with Z order 0 then drawing them with the correct Z order.

# doing this in the editor is gross and hard to change, so here we
# set up the required jiggery-pokery automatically.

# position within the viewport. this is semi-arbitrary but needs to
# leave enough room for all the animations to happen.
var GFX_POS = Vector2(600, 300)
var VP_SIZE = Vector2(1024, 600)

onready var ANIM_OBJ = $"../tricks"

func _ready():
	var sprite = $"sprite"
	var bones = $"bones"
	
	# pull the actual graphics off of us
	self.remove_child(sprite)
	self.remove_child(bones)
	
	# create a ViewportContainer to show the viewport
	var vpc = ViewportContainer.new()
	vpc.set_name("spr_view")
	# shift its position to cancel out the graphics shift
	vpc.rect_position = -GFX_POS
	vpc.rect_size = VP_SIZE
	
	# create the viewport that it will show
	var vp = Viewport.new()
	vp.set_name("spr_viewport")
	vp.size = VP_SIZE
	# don't put a background, we only want the player graphics
	vp.transparent_bg = true
	
	# shift the graphics to somewhere near the middle so
	# nothing gets clipped
	var gfx_pos = Position2D.new()
	gfx_pos.set_name("spr_pos")
	gfx_pos.global_position = GFX_POS
	
	# add the graphics as children so they get shifted
	gfx_pos.add_child(sprite)
	gfx_pos.add_child(bones)
	# show them in the viewport
	vp.add_child(gfx_pos)
	# render the viewport into the container
	vpc.add_child(vp)
	# and finally, we show the container
	self.add_child(vpc)

	# since we moved everything around, we have to fix up
	# the node paths too
	
	# fix the ones in the animation
	var anims = ANIM_OBJ.get_animation_list()
	for anim_name in anims:
		var anim = ANIM_OBJ.get_animation(anim_name)
		for path_idx in range(anim.get_track_count()):
			var path = anim.track_get_path(path_idx)
			if path.get_name_count() == 0 or path.get_name(0) != "graphics":
				continue
			var new_path = "graphics/spr_view/spr_viewport/spr_pos"
			for name_idx in range(1, path.get_name_count()):
				new_path += ("/"+path.get_name(name_idx))
			new_path += (":" + path.get_concatenated_subnames())
			anim.track_set_path(path_idx, NodePath(new_path))

