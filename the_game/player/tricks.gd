extends AnimationPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	#self.current_animation = "idle"
	pass # Replace with function body.

var last = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	return
	if last:
			self.current_animation = "sickflip"
	else:
		self.current_animation = "breake??"
	last = not last
