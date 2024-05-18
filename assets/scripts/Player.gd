extends Area2D
signal death

@export var AccelerationMod=6
#@export var SpeedMultipier=800
@export var Friction=10
@export var bulletScene :PackedScene
@export var laserScene:PackedScene
var bulletSpeed=300
var speed=800.0
#var screen_size
var play_size
var dead=false
var health=5
var maxHealth=5
var dashing=false
var velocity=Vector2.ZERO
const pierce=true
var maxSpeed=0
var shootCooldown=0.25
var barsflipped=false
var laserCharge=0
var laserExists=false
var laser

var shotgun=false
var canDash=false
var canLaser=true

#var dashspeed
#var speedmod=0
#var dashmod=0
var invincible=false 
#var dashes
# Called when the node enters the scene tree for the first time.
func _ready():
	play_size = get_viewport_rect().size
	
	#play_size=Vector2(screen_size.x,screen_size.y-150)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dashing:
		velocity/=1+Friction*delta
		velocity+= Input.get_vector('move_left','move_right','move_up','move_down')*speed*delta*AccelerationMod
		if Input.is_action_pressed("shoot") and $ShootCooldown.is_stopped() and not dead and not canDash and not canLaser:
			for x in range(1 if not shotgun else 5):
				var bullet = bulletScene.instantiate()
				bullet.position=position
				bullet.rotation=0 if not shotgun else randf_range(-0.35,0.35)
				bullet.move=Vector2(0,-bulletSpeed).rotated(bullet.rotation)
				bullet.range=INF if not shotgun else 300
				get_parent().add_child(bullet)
				$ShootCooldown.start()
		elif Input.is_action_just_pressed("shoot") and velocity.length() > 1 and $DashCooldown.is_stopped() and not dead and canDash:
			set_collision_layer_value(2,true)
			$CollisionShape2D.scale=Vector2(0.5,0.5)
			dashing=true
			velocity*=2
			$ExtraBar.tint_progress=Color(0,1,1)
			$DashTimer.start()
			invincible = true
			if velocity.length()<speed:
				velocity*=speed/velocity.length()
		elif Input.is_action_pressed("shoot") and not dead and canLaser and laserCharge<3:
			laserCharge+=delta
		elif not Input.is_action_pressed("shoot") and not dead and canLaser and laserCharge>1 and not laserExists:
			laserExists=true
			$ExtraBar.tint_progress=Color(1,0,0)
			laser=laserScene.instantiate()
			laser.scale=Vector2(5,5)
			laser.position=Vector2(0,-640-32)
			add_child(laser)
		if canDash:
			if $DashTimer.is_stopped():
				if $DashCooldown.is_stopped():$ExtraBar.tint_progress=Color(0,0.75,0.75)
				$ExtraBar.value=1-$DashCooldown.time_left/$DashCooldown.wait_time
			else:$ExtraBar.value=$DashTimer.time_left/$DashTimer.wait_time
		if laserExists:
			laserCharge-=delta
			if laserCharge<=0:
				laserExists=false
				#remove laser
				laser.queue_free()
		elif laserCharge>1:$ExtraBar.tint_progress=Color(0.9,0,0)
		if canLaser:$ExtraBar.value=laserCharge
	else:
		if $DashTimer.time_left<=0.1:
			$ExtraBar.tint_progress=Color(0,0.5,0.5)
			dashing=false
			set_collision_layer_value(2,false)
			$CollisionShape2D.scale=Vector2(0.3,0.3)
		$ExtraBar.value=$DashTimer.time_left/$DashTimer.wait_time
	if dead!=true:
		#if velocity.x>2:velocity.x=2
		#elif velocity.x<-2:velocity.x=-2
		#if velocity.y>2:velocity.y=2
		#if velocity.y<-2:velocity.y=-2
		position += velocity * delta 
		position = position.clamp(Vector2.ZERO, play_size)
		if not canLaser and ((position.y<64 and not barsflipped) or (position.y>64 and barsflipped)):
			$HealthBar.position.y*=-1
			$ExtraBar.position.y*=-1
			barsflipped=not barsflipped


func _on_body_entered(_body):
	if not invincible and not dead:
		health-=1
		if health<=0:
			dead=true
			death.emit()
		else:
			$InvincibleTimer.start()
			invincible=true
		update_health_bar()
		$HitSound.play()
		self.modulate=Color(1.0,1.0,1.0,0.5)
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

func start(full:bool=true):
	#velocity=Vector2.ZERO
	if canDash:
		$ExtraBar.show()
		$ExtraBar.tint_progress=Color(0,0.75,0.75)
		$DashCooldown.wait_time=shootCooldown*2
	elif canLaser:
		barsflipped=true
		$ExtraBar.show()
		$ExtraBar.tint_progress=Color(0.7,0,0)
		$ExtraBar.max_value=3
	else:
		if shotgun:shootCooldown*=2
		$ShootCooldown.wait_time=shootCooldown
	health=maxHealth
	self.modulate=Color(1.0,1.0,1.0,1)
	update_health_bar()
	#$HealthBar.max_value=health
	#speedmod=0
	#dashmod=0
	if full:
		show()
		dead=false
	

func _on_invincibility_timer_timeout():
	if not dead:
		self.modulate=Color(1.0,1.0,1.0,1.0)
		if not dashing:invincible = false


func _on_dash_end():
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
