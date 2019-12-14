extends Node2D

# rectangles of all the graffitable areas
var g_rect = []

onready var sprayer = $"../../player/graphics/sprayer"

func find_graffitables(node):
	var ours = []
	for child in node.get_children():
		for theirs in find_graffitables(child):
			ours.append(theirs)
		if child is MeshInstance2D:
			ours.append(child)
	return ours

func _ready():
	for graffitable in find_graffitables(self):
		var tex = graffitable.get_texture()
		var pos = graffitable.global_position-self.global_position
		var size = tex.get_size()*graffitable.global_scale
		g_rect.append(Rect2(pos-size/2, size))

var sprays = []

func _physics_process(delta):
	var spraying = Input.is_action_pressed("g_spray")
	if not spraying: return
	
	var spray_pos = sprayer.global_position-self.global_position
	
	for graffitable in range(len(g_rect)):
		var rect = g_rect[graffitable]
		if rect.has_point(spray_pos):
			sprays.append(spray_pos)
			self.update()

func _draw():
	for spray in sprays:
		self.draw_circle(spray, 20, Color(0, 0, 0, 1))
