extends Node2D

# for every graffitable object:
# rectangle representing its texture size
var g_rect = []
# canvasitem we use to draw onto it
var g_drawer = []
# queue of new sprays to add next frame
var g_sprays = []
# size of spray circle
var g_spray_size = []
# transform from global coordinates to local coordinates
# so we can draw the spray at the right place
var g_transform = []
# original texture so we can paint the object on the first frame
var g_tex = []

onready var sprayer = $"../../player/graphics/spray_pivot/sprayer"

var SPRAY_SIZE = 20

# any MeshInstance2Ds under us are object graphics and should be graffitable
func find_graffitables(node):
	var ours = []
	for child in node.get_children():
		for theirs in find_graffitables(child):
			ours.append(theirs)
		if child is MeshInstance2D:
			ours.append(child)
	return ours

func _ready():
	var g_idx = 0
	# transform each graffitable so we can draw on it
	for graffitable in find_graffitables(self):
		# get the original object texture
		var tex = graffitable.get_texture()
		# we have to keep the texture around so we can draw it to the new
		# thing we're about to make on the first frame. if we don't reference
		# it here, it will die by then.
		tex.reference()
		# size of the original object
		var size = tex.get_size()
		
		# we can't just draw on an arbitrary texture. we instead create a
		# viewport with an object we use for drawing
		var viewport = Viewport.new()
		viewport.size = tex.get_size()
		viewport.usage = Viewport.USAGE_2D
		# only clear the viewport initially, keep what we've sprayed after
		viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
		viewport.render_target_v_flip = true
		viewport.transparent_bg = true
		
		# a Node2D (or, well, a CanvasItem) is used for drawing operations
		var drawer = Node2D.new()
		viewport.add_child(drawer)
		drawer.position = Vector2(0, 0)
		drawer.scale = Vector2(1, 1)
		# get notification when it's about to be drawn
		drawer.connect("draw", self, "_g_draw", [g_idx])
		# instead of the original object, the graffitable now shows the viewport
		graffitable.set_texture(viewport.get_texture())
		# make sure we don't lose the viewport
		graffitable.get_parent().add_child(viewport)
		
		g_rect.append(Rect2(Vector2(0, 0), size))
		g_drawer.append(drawer)
		g_sprays.append([])
		var scale = graffitable.global_scale
		if scale.x > scale.y:
			g_spray_size.append(20/scale.x)
		else:
			g_spray_size.append(20/scale.y)
		g_transform.append(graffitable.get_global_transform().translated(-size/2).affine_inverse())
		g_tex.append([0, tex])

		g_idx += 1

func _physics_process(delta):
	var spraying = Input.is_action_pressed("g_spray")
	sprayer.set_spraying(spraying)
	if not spraying: return
	
	var spray_pos = sprayer.global_position
	
	for graffitable in range(len(g_rect)):
		var g_pos = g_transform[graffitable]*spray_pos
		if g_rect[graffitable].has_point(g_pos):
			g_sprays[graffitable].append(g_pos)
			g_drawer[graffitable].update()

func _g_draw(g_idx):
	
	if g_tex[g_idx] != null:
		var tex = g_tex[g_idx][1]
		if g_tex[g_idx][0] == 0:
			# draw the original object texture as the very first thing 
			g_drawer[g_idx].draw_texture(tex, Vector2(0, 0))
			# then free it next frame
			g_tex[g_idx][0] = 1
		elif g_tex[g_idx][0] == 1:
			# free the texture now that it's been drawn
			tex.unreference()
			g_tex[g_idx] = null
	if len(g_sprays[g_idx]) > 0:
		var drawer = g_drawer[g_idx]
		var spray_size = g_spray_size[g_idx]
		var color = Color(0, 0, 0, 1)
		for spray in g_sprays[g_idx]:
			drawer.draw_circle(spray, spray_size, color)
		g_sprays[g_idx] = []
