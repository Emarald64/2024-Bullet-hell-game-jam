extends Area2D
signal death

@export var AccelerationMod=10
#@export var SpeedMultipier=800
@export var Friction=10
@export var bulletScene :PackedScene
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

var shotgun=false
var canDash=true

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
		if Input.is_action_pressed("shoot") and $ShootCooldown.is_stopped() and not dead and not canDash:
			for x in range(1 if not shotgun else 5):
				var bullet = bulletScene.instantiate()
				bullet.position=position
				bullet.rotation=0 if not shotgun else randf_range(-0.35,0.35)
				bullet.move=Vector2(0,-bulletSpeed).rotated(bullet.rotation)
				bullet.range=INF if not shotgun else 300
				get_parent().add_child(bullet)
				$ShootCooldown.start()
		elif Input.is_action_just_pressed("shoot") and velocity.length() > 1 and $DashCooldown.is_stopped() and canDash:
			set_collision_layer_value(2,true)
			dashing=true
			velocity*=4
			$ExtraBar.tint_progress=Color(0,1,1)
			$DashTimer.start()
			invincible = true
			if velocity.length()<speed:
				velocity*=speed/velocity.length()
		if canDash:
			if $DashTimer.is_stopped():
				if $DashCooldown.is_stopped():$ExtraBar.tint_progress=Color(0,0.75,0.75)
				$ExtraBar.value=1-$DashCooldown.time_left/$DashCooldown.wait_time
			else:$ExtraBar.value=$DashTimer.time_left/$DashTimer.wait_time
	else:
		if $DashTimer.time_left<=0.1:
			$ExtraBar.tint_progress=Color(0,0.5,0.5)
			dashing=false
			set_collision_layer_value(2,false)
		$ExtraBar.value=$DashTimer.time_left/$DashTimer.wait_time
	if dead!=true:
		#if velocity.x>2:velocity.x=2
		#elif velocity.x<-2:velocity.x=-2
		#if velocity.y>2:velocity.y=2
		#if velocity.y<-2:velocity.y=-2
		position += velocity * delta 
		position = position.clamp(Vector2.ZERO, play_size)
		if (position.y<64 and not barsflipped) or (position.y>64 and barsflipped):
			$HealthBar.position.y*=-1
			$ExtraBar.position.y*=-1
			barsflipped=not barsflipped


func _on_body_entered(_body):
	if not invincible:
		health-=1
		update_health_bar()
		$HitSound.play()
		if health<=0:
			dead=true
			death.emit()
		$InvincibleTimer.start()
		self.modulate=Color(1.0,1.0,1.0,0.5)
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
	
func start(full:bool=true):
	#velocity=Vector2.ZERO
	if canDash:
		$ExtraBar.show()
		$ExtraBar.tint_progress=Color(0,0.75,0.75)
		$DashCooldown.wait_time=shootCooldown*2
	else:
		$ShootCooldown.wait_timer=shootCooldown
	health=maxHealth
	update_health_bar()
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
