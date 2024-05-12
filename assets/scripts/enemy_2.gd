extends RigidBody2D

var moveSpeed=150
var bulletSpeed=200
var screen_size
var dieing=false
var spawning=true
@export var bulletScene: PackedScene
@export var spikeScene: PackedScene
var numSpikes=4
# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(numSpikes):
		var spike=spikeScene.instantiate()
		spike.rotation=(x*TAU/numSpikes)+PI/2
		spike.position=Vector2(cos(x*TAU/numSpikes),sin(x*TAU/numSpikes))
		spike.body_entered.connect(on_spike_hit.bind(spike))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_spike_hit(body,spike):
	spike.queue_free()
	numSpikes-=1
	if numSpikes==0:
		# Add exploasion
		queue_free()
