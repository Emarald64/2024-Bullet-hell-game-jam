extends Area2D
signal dash

@export var AccelerationDivider=3
@export var SpeedMultipier=800
@export var Friction=1.5
var speed=400.0
var screen_size
var play_size
var dead
var health=5
var maxHealth=5
var dashing=false
var velocity=Vector2.ZERO
var dashspeed
var speedmod=0
var dashmod=0
var invincible=false 
var dashes
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	play_size=Vector2(screen_size.x,screen_size.y-150)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $DashTimer.time_left>=0.1:
		velocity/=Friction
		if Input.is_action_pressed("move_right"):
			velocity.x += speed/AccelerationDivider
		if Input.is_action_pressed("move_left"):
			velocity.x -= speed/AccelerationDivider
		if Input.is_action_pressed("move_down"):
			velocity.y += speed/AccelerationDivider
		if Input.is_action_pressed("move_up"):
			velocity.y -= speed/AccelerationDivider
		if Input.is_action_just_pressed("dash") and velocity.length() > 0 and $DashCooldown.is_stopped():
			dash.emit()
			dashing=true
			velocity*=2+(dashmod/2.0)
			$DashTimer.start()
			invincible = true
			if velocity.length()<speed/2:
				velocity*=speed/2/velocity.length()
		if Input.is_action_just_pressed("debug_hit"):
			health-=1
			update_health_bar()

	if dead!=true:
		#if velocity.x>2:velocity.x=2
		#elif velocity.x<-2:velocity.x=-2
		#if velocity.y>2:velocity.y=2
		#if velocity.y<-2:velocity.y=-2
		position += velocity * delta 
		position = position.clamp(Vector2.ZERO, play_size)


func _on_body_entered(_body):
	print('Hit!')
	if not invincible:
		health-=1
		update_health_bar()
		$InvincibleTimer.start()
		self.modulate=Color(1.0,1.0,1.0,0.5)
		$HitSound.play()
		# Must be deferred as we can't change physics properties on a physics callback.
		invincible=true
#const powers=['health','dash','speed']
	#elif body.get_meta('OnHit')=='power':
		#if body.power=='health':emit_signal('heal')
		#elif body.power=='dash':
			#dashmod+=1
			#$DashCooldown.wait_time=(dashmod+1)/(2*dashmod+1)
		#elif body.power=='speed':
			#speedmod+=1
			#speed=((-1.0/(speedmod+3))+1)*SpeedMultipier
		#body.queue_free()
	
func start():
	velocity=Vector2.ZERO
	dead=false
	speedmod=0
	dashmod=0
	show()
	

func _on_invincibility_timer_timeout():
	self.modulate=Color(1.0,1.0,1.0,1.0)
	if not dashing:invincible = false


func _on_dash_end():
	dashing=false
	$DashCooldown.start()
	if $InvincibleTimer.is_stopped():invincible = false
	
func update_health_bar():
	$HealthBar.value=health
	$HealthBar.max_value=maxHealth
	if health==1:
		$HealthBar.tint_progress=Color(1,0,0)
	elif health<=maxHealth/2.0:
		$HealthBar.tint_progress=Color(1,1,0)
	else:
		$HealthBar.tint_progress=Color(0,1,0)
