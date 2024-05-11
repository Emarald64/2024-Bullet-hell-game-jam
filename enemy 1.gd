extends Node2D

var moveSpeed=150
var bulletSpeed=200
var screen_size
var dieing=false
@export var bulletScene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dieing:
		position.x+=moveSpeed*delta
		if position.x>screen_size.x:moveSpeed*=-1
		elif position.x<0:moveSpeed*=-1


func _on_bullet_timer_timeout():
	if not dieing:
		var bullet = bulletScene.instantiate()
		bullet.position=position
		bullet.linear_velocity=Vector2(0,bulletSpeed)
		get_parent().add_child(bullet)


func hit(body):
	if not body.pierce or dieing:
		body.queue_free()
	dieing=true
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion.play()
	


func _on_animated_sprite_2d_animation_finished():
	queue_free()
