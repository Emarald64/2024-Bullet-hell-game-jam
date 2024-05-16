extends Node2D
@export var enemy1:PackedScene
@export var enemy2:PackedScene
@export var enemy3:PackedScene
@export var cardScene:PackedScene
var roundTick=0
var screen_size
var enemies={0:3}
var enemyCount:int
var liveEnemies=0
var roundNumber=0

var upgradeStats={
	'playerFireCooldown':0.25,
	'playerHealth':5, 
	'playerBulletSpeed':300, 
	'playerSpeed':400,

	'enemy1Speed':150,
	'enemy1BulletSpeed':200,
	'enemy1FireCooldown':1,

	'enemy2Spikes':4,
	'enemy2Speed':250,
	'enemy2BulletSpeed':200,
	'enemy2Spin':PI,
	'enemy2FireCooldown':1.75,
	
	'enemy3Speed':600,
	'enemy3Delay':1,
	'enemy3ExplosionSize':180,
	}
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	start_round()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("debug_spawn_enemy1"):spawn_enemy1()
	if Input.is_action_just_pressed("debug_spawn_enemy2"):spawn_enemy2()
	if Input.is_action_just_pressed("debug_spawn_enemy3"):spawn_enemy3()
func start_round():
	const rounds=[
		{0:3},
		{0:1,5:1,10:1,15:1,20:1},
		{0:1,5:1,10:1,70:2},
		{0:1,5:1,10:1,15:1,20:1,40:2,50:2},
		{0:2,10:2,15:2,115:1,120:1,125:1,130:1,150:2},
		{0:3,30:1,35:1,40:1,45:1,50:1,70:2,80:2,85:3,100:2},
		{0:1,5:1,10:1,15:1,20:1,40:2,50:2,55:3,60:2,100:2,120:2,300:3,1000:3},
		{},
		{},
		{} #final
	]
	enemies=rounds[roundNumber]
	$Player.maxHealth=upgradeStats['playerHealth']
	$Player.bulletSpeed=upgradeStats['playerBulletSpeed']
	$Player.speed=upgradeStats['playerSpeed']
	get_node('Player/ShootCooldown').wait_time=upgradeStats['playerFireCooldown']
	$Player.start()
	roundTick=0
	liveEnemies=0
	$RoundTimer.start()
	enemyCount=len(enemies.keys())

# round layout
# Dictonary with keys as times and values as enemy numbers
# times are in 0.1 seconds
# values are the enemy number
# call to start round $RoundTimer.start()

func spawnRound():
	if roundTick in enemies.keys():
		if enemies[roundTick]==1:
			spawn_enemy1()
			liveEnemies+=1
		elif enemies[roundTick]==2:
			spawn_enemy2()
			liveEnemies+=1
		elif enemies[roundTick]==3:
			spawn_enemy3()
			liveEnemies+=1
	roundTick+=1

func spawn_enemy1():
	var enemy=enemy1.instantiate()
	var direction=randi_range(0,1)
	enemy.position=Vector2([-16,screen_size.x+16][direction],16)
	enemy.dead.connect(on_enemy_death)
	enemy.moveSpeed=upgradeStats['enemy1Speed']*(direction*-2+1)
	enemy.bulletSpeed=upgradeStats['enemy1BulletSpeed']
	enemy.FireCooldown=upgradeStats['enemy1FireCooldown']
	add_child(enemy)

func spawn_enemy2():
	var enemy=enemy2.instantiate()
	enemy.position=Vector2(randi_range(40,screen_size.x-40),-32)
	enemy.move=Vector2(upgradeStats['enemy2Speed']*[-1,1][randi_range(0,1)],upgradeStats['enemy2Speed'])
	enemy.moveSpeed=upgradeStats['enemy2Speed']
	enemy.bulletSpeed=upgradeStats['enemy2BulletSpeed']
	enemy.numSpikes=max(int(upgradeStats['enemy2Spikes']),1)
	enemy.spin=upgradeStats['enemy2Spin']
	enemy.dead.connect(on_enemy_death)
	enemy.get_node('ShootTimer').wait_time=upgradeStats['enemy2FireCooldown']
	add_child(enemy)

func spawn_enemy3():
	var enemy=enemy3.instantiate()
	enemy.position=Vector2(-100 if $Player.position.x>screen_size.x/2 else screen_size.x+100,-100)
	enemy.player=$Player
	enemy.dead.connect(on_enemy_death)
	enemy.speed=upgradeStats['enemy3Speed']
	enemy.explosionSize=upgradeStats['enemy3ExplosionSize']
	add_child(enemy)

func on_enemy_death():
	enemyCount-=1
	liveEnemies-=1
	if enemyCount==0:
		for node in get_children():
			if node.get_meta('bullet', false):node.queue_free()
		$RoundTimer.stop()
		upgradeMenu()
	elif liveEnemies==0:roundTick=enemies.keys().filter(func(number): return number>roundTick).min()

func upgradeMenu():
	var background=ColorRect.new()
	background.color=Color(0,0,0,0.5)
	background.size=screen_size
	background.z_index=1
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
			'enemy2BulletSpeed':['enemy2 Bullet speed',0,0],
			'enemy2Spin':['enemy2 spin speed',1,1],
			'enemy2FireCooldown':['enemy2 fire rate',1,0],
			'enemy3Speed':['enemy3 speed',0,0],
			'enemy3Delay':['enemy3 explosion delay',0,0],
			'enemy3ExplosionSize':['enemy3 explosion size',0,0]}
		var upside=stats.keys().pick_random()
		while (upside=='enemy2Spikes' and upgradeStats['enemy2Spikes']<2) or (upside in ['playerSpeed','playerBulletSpeed'] and upgradeStats[upside]>1000) or ('enemy2' in upside and roundNumber<=0) or ('enemy3' in upside and roundNumber<=2):upside=stats.keys().pick_random()
		const powers=[[0.9,1.1],[0.8,1.25],[0.67,1.5],[0.5,2],[0.4,2.5]]
		var upsidePower=x+randi_range(1,2)
		card.get_node("Upsides").text='x'+str(powers[upsidePower][stats[upside][2]])+' '+stats[upside][0]
		var downside=upside
		while downside==upside or ('speed' in downside and upgradeStats[downside]>1000 and downside not in ['playerSpeed','playerBulletSpeed']) or ('enemy2' in downside and roundNumber<=0) or ('enemy3' in downside and roundNumber<=2):downside=stats.keys().pick_random()
		var downsidePower=upsidePower-randi_range(0,1)
		card.get_node("Downsides").text='x'+str(powers[downsidePower][stats[downside][2]*-1+1])+' '+stats[downside][0]
		card.position=Vector2(screen_size.x/2-432+288*x,screen_size.y/2-168)
		card.set_meta('Powers',[upside,powers[upsidePower][stats[upside][1]],downside,powers[downsidePower][stats[downside][1]*-1+1]])
		card.get_node('Button').pressed.connect(card_clicked.bind(card))
		background.add_child(card)
	add_child(background)

func card_clicked(card):
	var meta=card.get_meta('Powers')
	upgradeStats[meta[0]]*=meta[1] #set upside
	upgradeStats[meta[2]]*=meta[3] #set downside
	card.get_parent().queue_free()
	roundNumber+=1
	start_round()


func _on_player_death():
	$DeathScreen/Score.text='Score: '+str(roundNumber)
	$AnimationPlayer.play('Show Death Screen')
	for node in get_children():
			if node.get_meta('bullet', false):node.queue_free()
	
