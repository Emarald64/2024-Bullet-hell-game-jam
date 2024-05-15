extends Area2D

signal dead
var player
var speed=500
var friction=1
var velocity:Vector2=Vector2.ZERO
var explosionDelay=1
var exploading=false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position+=velocity*delta
	if not exploading:
		velocity+=(player.position-position).normalized()*speed*delta
	velocity*=1/(1+(delta*friction))
	if ((velocity/(1+friction))+position).distance_to(player.position)<200 and not exploading:
		exploading=true
		print("hiss")
		$ExplosionTimer.start()


func _on_explosion_timer_timeout():
	print('BOOM')
	$ExplosionCollision.disabled=false
	$Explosion.play()
	$Explosion.show()
	$Sprite2D.hide()


func _on_explosion_animation_finished():
	dead.emit()
	queue_free()
