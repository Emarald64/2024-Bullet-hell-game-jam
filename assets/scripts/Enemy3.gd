extends Area2D

signal dead
var player
var speed=600
var friction=1
var velocity:Vector2=Vector2.ZERO
var explosionDelay=1
var exploading=false
var lastRotation=0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite2D.rotation=velocity.angle()+(3*PI/4)
	position+=velocity*delta
	if not exploading:
		velocity+=(player.position-position).normalized()*speed*delta
	else:rotation=lastRotation+($ExplosionTimer.time_left/explosionDelay*TAU)
	velocity*=1/(1+(delta*friction))
	
	draw_line(position,(velocity/(1+(friction*explosionDelay)))+position,Color.WHITE)
	if ((velocity/(1+(friction*explosionDelay)))+position).distance_to(player.position)<150 and not exploading:
		print('hiss')
		exploading=true
		lastRotation=rotation
		$ExplosionTimer.start()

func start_exploasion(body):
	if not exploading:
		exploading=true
		lastRotation=rotation
		$ExplosionTimer.start()

func _on_explosion_timer_timeout():
	$ExplosionCollision.disabled=false
	$Explosion.play()
	$Explosion.show()
	$Sprite2D.hide()


func _on_explosion_animation_finished():
	dead.emit()
	queue_free()
