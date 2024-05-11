extends Node2D

var moveSpeed=150
var screen_size
@export var bulletScene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x+=moveSpeed*delta
	if position.x>screen_size.x:moveSpeed*=-1
	elif position.x<0:moveSpeed*=-1


func _on_bullet_timer_timeout():
	var bullet = bulletScene.instantiate()
	bullet.position=position
	get_parent().add_child(bullet)
