extends Area2D

var move:Vector2
var screen_size:Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position+=move*delta
	if position.x<0 or position.x>screen_size.x:
		move.x*=-1
		rotation*=-1
	if position.y<0 or position.y>screen_size.y:
		move.y*=-1
		rotation=-1*rotation+PI


func _on_life_timer_timeout():
	queue_free()
