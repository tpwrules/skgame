extends Node2D

# rectangles of all the graffitable areas
var g_rect = []
# and nodes we can use to draw on them
var g_drawer = []
# and queues of new sprays to add
var g_sprays = []
# and the scale of each thing on the screen
var g_scale = []

onready var sprayer = $"../../player/graphics/spray_pivot/sprayer"

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
	for graffitable in find_graffitables(self):
		var tex = graffitable.get_texture()
		var pos = graffitable.global_position-self.global_position
		var size = tex.get_size()*graffitable.global_scale
		
		# we want to make a texture we can draw random garbage on.
		# we do this with a custom viewport.
		var viewport = Viewport.new()
		viewport.size = tex.get_size()
		viewport.usage = Viewport.USAGE_2D
		viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
		viewport.render_target_v_flip = true
		viewport.transparent_bg = true
		
		# a node2D is used for drawing operations
		var drawer = Node2D.new()
		viewport.add_child(drawer)
		drawer.position = Vector2(0, 0)
		drawer.scale = Vector2(1, 1)
		# get notification when it's about to be drawn
		drawer.connect("draw", self, "_on_draw", [g_idx])

		# the garbage gets drawn masked by a mesh of the same shape as the actual texture
		var tex_mesh = graffitable.get_mesh()
		var vp_instance = MeshInstance2D.new()
		vp_instance.set_mesh(tex_mesh)
		vp_instance.set_texture(viewport.get_texture())
		
		graffitable.get_parent().add_child(vp_instance)
		graffitable.get_parent().add_child(viewport)
		vp_instance.global_position = graffitable.global_position
		vp_instance.global_scale = graffitable.global_scale
		vp_instance.z_index = 999
		vp_instance.z_as_relative = false

		
		g_rect.append(Rect2(pos-size/2, size))
		g_drawer.append(drawer)
		g_sprays.append([])
		g_scale.append(graffitable.global_scale)
		g_idx += 1

var sprays = []

func _physics_process(delta):
	var spraying = Input.is_action_pressed("g_spray")
	sprayer.set_spraying(spraying)
	if not spraying: return
	
	var spray_pos = sprayer.global_position-self.global_position
	
	for graffitable in range(len(g_rect)):
		var rect = g_rect[graffitable]
		if rect.has_point(spray_pos):
			g_sprays[graffitable].append(spray_pos-rect.position)
			g_drawer[graffitable].update()

func _on_draw(g_idx):
	if len(g_sprays[g_idx]) > 0:
		var scale = g_scale[g_idx]
		for spray in g_sprays[g_idx]:
			g_drawer[g_idx].draw_circle(spray/scale, 20/scale.x, Color(0, 0, 0, 1))
		g_sprays[g_idx] = []
