extends Area2D

var move:Vector2
var moveSpeed
var bulletSpeed=200
var screen_size
var dieing=false
var spawning=true
@export var bulletScene: PackedScene
@export var spikeScene: PackedScene
var numSpikes=4
var spin=PI
var spikes:Array
signal dead
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	for x in range(numSpikes):
		var spike=spikeScene.instantiate()
		spike.rotation=(x*TAU/numSpikes)-PI/2
		spike.position=Vector2(cos(x*TAU/numSpikes),sin(x*TAU/numSpikes))*41
		spike.scale=Vector2(1.5,1.5)
		spike.body_entered.connect(on_spike_hit.bind(spike))
		spikes.append(spike)
		add_child(spike)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position+=move*delta
	if spawning:
		if position.y>0:spawning=false
	else:
		if position.x<0:move.x=moveSpeed
		elif position.x>screen_size.x:move.x=-moveSpeed
		if position.y<0:move.y=moveSpeed
		elif position.y>screen_size.y:move.y=-moveSpeed
	rotation+=spin*delta

func on_spike_hit(body,spike):
	spike.queue_free()
	numSpikes-=1
	body.queue_free()
	spikes.erase(spike)
	if numSpikes==0:
		# Add exploasion
		dead.emit()
		set_deferred('monitorable',false)
		set_deferred('monitoring',false)
		$Sprite2D.hide()
		$Explosion.show()
		$Explosion.play()
		move=Vector2.ZERO
		spin=0

func shoot():
	for spike in spikes:
		var bullet=bulletScene.instantiate()
		bullet.position=spike.position.rotated(rotation)+position
		bullet.rotation=spike.rotation+rotation
		bullet.move=Vector2(bulletSpeed,0).rotated(spike.rotation+rotation+PI/2)
		add_sibling(bullet)


func _on_body_entered(body):
	body.queue_free()
	# add effect to show bullet deletion
