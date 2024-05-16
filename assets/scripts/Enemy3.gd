extends Area2D

signal dead
var player
var speed=600
var explosionSize=200
var friction=1.2
var velocity:Vector2=Vector2.ZERO
var explosionDelay=1
var exploading=false
var lastRotation=0
var lastPosition=Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	$ExplosionCollision.shape.radius=explosionSize
	$Explosion.scale=Vector2(explosionSize*3/100,explosionSize*3/100)

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
	if not exploading:DebugDraw2D.circle((velocity*0.5**(friction*explosionDelay))+position,explosionSize/2)
	else:DebugDraw2D.circle(lastPosition,explosionSize)
	
	if ((velocity*0.5**(friction*explosionDelay))+position).distance_to(player.position)<explosionSize/2 and not exploading and not player.dead and $VisibleOnScreenNotifier2D.is_on_screen():
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
	if not player.dead:dead.emit()
	queue_free()
