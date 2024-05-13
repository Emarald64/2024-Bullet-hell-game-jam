extends Control
var screen_size:Vector2
@export var cardScene:PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	for x in range(3):
		# create card
		var card=cardScene.instantiate()
		# create card stats
		#upside
		# vairable name:[common name,do(-/+),say(-/+)]
		const stats={
			'playerFireCooldown':['fire rate',0,1],
			'playerHealth':['health',1,1],
			'playerBulletSpeed':['bullet speed',1,1],
			'playerSpeed':['Speed',1,1],
			'enemy1Speed':['enemy1 speed',0,0],
			'enemy1BulletSpeed':['enemy1 bullet speed',0,0],
			'enemy1FireCooldown':["enemy1 fire rate",1,0],
			'enemy2Spikes':['enemy2 spikes',0,0],
			'enemy2Speed':['enemy2 speed',0,0],
			'enemy2Spin':['enemy2 spin speed',1,1],
			'enemy2FireCooldown':['enemy2 fire rate',1,0]}
		var upside=stats.keys().pick_random()
		const powers=[[0.9,1.1],[0.8,1.25],[0.67,1.5],[0.5,2],[0.4,2.5]]
		var upsidePower=x+randi_range(1,2)
		card.get_node("Text container/Upsides").text='x'+str(powers[upsidePower][stats[upside][2]])+' '+stats[upside][0]
		var downside=upside
		while downside==upside:downside=stats.keys().pick_random()
		var downsidePower=upsidePower-randi_range(0,1)
		card.get_node("Text container/Downsides").text='x'+str(powers[downsidePower][stats[downside][2]*-1+1])+' '+stats[downside][0]
		card.position=Vector2(screen_size.x/2-432+288*x,screen_size.y/2-168)
		card.set_meta('Powers',[upside,powers[upsidePower][stats[upside][1]],downside,powers[downsidePower][stats[downside][1]*-1+1]])
		card.get_node('Button').pressed.connect(card_clicked.bind(card))
		add_child(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func card_clicked(card):
	pass
