extends Area2D

signal dead
var player
var speed=600
var friction=1
var velocity:Vector2=Vector2.ZERO
var explosionDelay=1
var exploading=false
var lastRotation=0
var lastPosition=Vector2.ZERO
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
	#velocity*=0.5**(0.5*friction*delta)
	velocity*=1/(1+(delta*friction))
	
	#debug circle
	#if not exploading:DebugDraw2D.circle((velocity*0.5**(friction*explosionDelay))+position,100)
	if exploading:DebugDraw2D.circle(lastPosition,64)
	if ((velocity*0.5**(friction*explosionDelay))+position).distance_to(player.position)<100 and not exploading and not player.dead:
		exploading=true
		lastRotation=rotation
		lastPosition=(velocity*0.5**(0.5*friction*explosionDelay))+position
		$ExplosionTimer.start()

func start_exploasion(_body):
	if not exploading:
		exploading=true
		lastRotation=rotation
		lastPosition=(velocity*0.5**(0.5*friction*explosionDelay))+position
		$ExplosionTimer.start()

func _on_explosion_timer_timeout():
	if player.dead:
		exploading=false
	else:
		$ExplosionCollision.disabled=false
		$Explosion.play()
		$Explosion.show()
		$Sprite2D.hide()


func _on_explosion_animation_finished():
	dead.emit()
	queue_free()
