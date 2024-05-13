extends Node2D
@export var enemy1:PackedScene
@export var enemy2:PackedScene
@export var cardScene:PackedScene
var roundTick=0
var screen_size
var enemies={0:1,5:1,10:1,15:1,20:1,100:2,150:2}
var enemyCount:int
var liveEnemies=0


var playerFireCooldown=0.25 #done
var playerHealth=5 #done
var playerBulletSpeed=300 #done
var playerSpeed=400

var enemy1Speed=150 #done
var enemy1BulletSpeed=200 #done
var enemy1FireCooldown=1 #done

var enemy2Spikes=4 #done
var enemy2Speed=150 #done
var enemy2BulletSpeed=200 #done
var enemy2Spin=PI
var enemy2FireCooldown=1.75 #done
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	start_round()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_spawn_enemy1"):spawn_enemy1()
	if Input.is_action_just_pressed("debug_spawn_enemy2"):spawn_enemy2()

func start_round():
	$Player.maxHealth=playerHealth
	$Player.bulletSpeed=playerBulletSpeed
	$Player.speed=playerSpeed
	get_node('Player/ShootCooldown').wait_time=playerFireCooldown
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
	roundTick+=1

func spawn_enemy1():
	var enemy=enemy1.instantiate()
	var direction=randi_range(0,1)
	enemy.position=Vector2([-16,screen_size.x+16][direction],0)
	enemy.dead.connect(on_enemy_death)
	enemy.moveSpeed=enemy1Speed*(direction*-2+1)
	enemy.bulletSpeed=enemy1BulletSpeed
	enemy.FireCooldown=enemy1FireCooldown
	add_child(enemy)

func spawn_enemy2():
	var enemy=enemy2.instantiate()
	enemy.position=Vector2(randi_range(40,screen_size.x-40),-32)
	enemy.move=Vector2([-enemy2Speed,enemy2Speed][randi_range(0,1)],enemy2Speed)
	enemy.bulletSpeed=enemy2BulletSpeed
	enemy.numSpikes=int(enemy2Spikes)
	enemy.spin=enemy2Spin
	enemy.dead.connect(on_enemy_death)
	enemy.get_node('ShootTimer').wait_time=enemy2FireCooldown
	add_child(enemy)

func on_enemy_death():
	enemyCount-=1
	liveEnemies-=1
	if enemyCount==0:
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
			'enemy2FireCooldown':['enemy2 fire rate',1,0]}
		var upside=stats.keys().pick_random()
		const powers=[[0.9,1.1],[0.8,1.25],[0.67,1.5],[0.5,2],[0.4,2.5]]
		var upsidePower=x+randi_range(1,2)
		card.get_node("Upsides").text='x'+str(powers[upsidePower][stats[upside][2]])+' '+stats[upside][0]
		var downside=upside
		while downside==upside:downside=stats.keys().pick_random()
		var downsidePower=upsidePower-randi_range(0,1)
		card.get_node("Downsides").text='x'+str(powers[downsidePower][stats[downside][2]*-1+1])+' '+stats[downside][0]
		card.position=Vector2(screen_size.x/2-432+288*x,screen_size.y/2-168)
		card.set_meta('Powers',[upside,powers[upsidePower][stats[upside][1]],downside,powers[downsidePower][stats[downside][1]*-1+1]])
		card.get_node('Button').pressed.connect(card_clicked.bind(card))
		background.add_child(card)
	add_child(background)

func card_clicked(card):
	var meta=card.get_meta('Powers')
	print(meta)
	print(get(meta[0]))
	set(meta[0],get(meta[0])*meta[1]) #set upside
	set(meta[2],get(meta[2])*meta[3]) #set downside
	card.get_parent().queue_free()
	start_round()
