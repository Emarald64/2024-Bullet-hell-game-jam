extends Area2D

var pierce=false
var range=INF
var move=Vector2(0,300)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position+=move*delta
	range-=move.length()*delta
	if range<50:modulate=Color(1,1,1,range/50)
	elif range<0:queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
