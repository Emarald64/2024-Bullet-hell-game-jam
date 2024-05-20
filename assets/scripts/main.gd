extends Node2D
@export var enemy1:PackedScene
@export var enemy2:PackedScene
@export var enemy3:PackedScene

@export var bossScene:PackedScene
@export var spikeScene:PackedScene
@export var bullet1Scene:PackedScene
@export var bullet2Scene:PackedScene

@export var cardScene:PackedScene
var roundTick=0
var screen_size
var enemies:Dictionary
var enemyCount:int
var liveEnemies=0
var roundNumber=0

var lastPlayerPos:Vector2=Vector2.ZERO
#var playTestUpgrades=[]

var bossExists=false
var bossNodes=[]
var bossSpikes=[]
var bossSpeed=300
var bossMaxHealth=100
var bossHealth=100

const defaultUpgradeStats={
	'playerFireCooldown':0.25,
	'playerHealth':4, 
	'playerBulletSpeed':300, 
	'playerSpeed':800,

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
var upgradeStats:Dictionary
var specialUpgrade='none'
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	get_node('DeathScreen/Button').pressed.connect(goReset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if roundNumber==9:boss_process(delta)
	if not $ResetPlayerTimer.is_stopped():
		$Player.position=lastPlayerPos.lerp(Vector2(576,432),1-$ResetPlayerTimer.time_left*2)
	if Input.is_action_just_pressed("debug_spawn_enemy1"):spawn_enemy1()
	if Input.is_action_just_pressed("debug_spawn_enemy2"):spawn_enemy2()
	if Input.is_action_just_pressed("debug_spawn_enemy3"):spawn_enemy3()

func start_game():
	upgradeStats=defaultUpgradeStats.duplicate()
	roundNumber=9
	#playTestUpgrades=[]
	specialUpgrade='none'
	$Player.position=Vector2(576,432)
	$Player.start(true)
	start_round()

func start_round():
	const rounds=[
		{0:1,5:1,10:1,15:1,20:1},
		{0:1,5:1,10:1,70:2},
		{0:1,5:1,10:1,15:1,20:1,40:2,50:2},
		{0:2,10:2,15:2,115:1,120:1,125:1,130:1,150:2},
		{0:1,5:1,6:2,10:1,15:1,16:2,20:1,25:1,26:2,30:1,40:2},
		{0:3,30:1,35:1,40:1,45:1,50:1,60:3,70:2,80:2,85:3,100:2},
		{0:1,5:1,10:1,15:1,20:1,40:2,50:2,55:3,60:2,100:2,120:2,300:3,1000:3},
		{0:1,3:1,6:1,9:1,12:1,15:1,18:1,21:1,35:3,50:2,70:2,90:2,100:3,110:2,115:1,120:1,125:1,130:1,150:3},
		{0:2,1:1,6:1,10:2,11:1,16:1,19:3,20:2,21:1,26:1,30:2,31:1,36:1,40:2},
		{0:666}# =>
		]
	enemies=rounds[roundNumber]
	$Player.maxHealth=int(upgradeStats['playerHealth'])
	$Player.bulletSpeed=upgradeStats['playerBulletSpeed']
	$Player.speed=upgradeStats['playerSpeed']
	$Player.shotgun='shotgun' == specialUpgrade
	$Player.canDash='dash' == specialUpgrade
	$Player.canLaser='laser' == specialUpgrade
	$Player.shootCooldown=upgradeStats['playerFireCooldown']
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
		elif enemies[roundTick]==666:
			spawn_boss()
			liveEnemies+=1
	if typeof(roundTick)!=0:roundTick+=1

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
	enemy.explosionDelay=upgradeStats['enemy3Delay']
	enemy.dead.connect(on_enemy_death)
	enemy.speed=upgradeStats['enemy3Speed']
	
	enemy.explosionSize=upgradeStats['enemy3ExplosionSize']
	add_child(enemy)

func spawn_boss():
	bossMaxHealth=5#upgradeStats['playerHealth']*30
	bossHealth=bossMaxHealth
	$BossShootTimer.start()
	$BossHealthBar.show()
	$BossHealthBar.value=bossHealth
	$BossHealthBar.max_value=bossMaxHealth
	for x in range(5):
		var part=bossScene.instantiate()
		part.progress=84*x
		part.get_node('Area2D').area_entered.connect(boss_hit.bind(1))
		part.get_node('Area2D').scale=Vector2(1.5,1.5)
		for y in range(upgradeStats['enemy2Spikes']):
			var spike=spikeScene.instantiate()
			spike.rotation=(y*TAU/upgradeStats['enemy2Spikes'])-PI/2
			spike.position=Vector2(cos(y*TAU/upgradeStats['enemy2Spikes']),sin(y*TAU/upgradeStats['enemy2Spikes']))*40
			spike.scale=Vector2(1.2,1.2)
			spike.area_entered.connect(boss_hit.bind(2))
			bossSpikes.append(spike)
			part.get_node('Area2D').add_child(spike)
		bossNodes.append(part)
		$BossPath.add_child(part)
	bossExists=true

func on_enemy_death():
	enemyCount-=1
	liveEnemies-=1
	if enemyCount==0:
		for node in get_children():
			if node.get_meta('bullet', false):node.queue_free()
		$RoundTimer.stop()
		if roundNumber>=9:
			$Player.queue_free()
			$EndScreen.show()
			#get_node('EndScreen/TextEdit').text=str(playTestUpgrades)+' '+str($Player.playTestHits)
		else:upgradeMenu()
	elif liveEnemies==0:roundTick=enemies.keys().filter(func(number): return number>roundTick).min()

func upgradeMenu():
	var background=ColorRect.new()
	background.color=Color(0,0,0,0.5)
	background.size=screen_size
	background.z_index=1
	for x in range(3):
		# create card
		var card=cardScene.instantiate()
		# vairable name:[common name,do(-/+),say(-/+)]
		const stats={
			'playerFireCooldown':['fire rate',0,1],
			'playerHealth':['health',1,1],
			'playerBulletSpeed':['bullet speed',1,1],
			'playerSpeed':['Speed',1,1],
			'enemy1Speed':['Crusier speed',0,0],
			'enemy1BulletSpeed':['Crusier bullet speed',0,0],
			'enemy1FireCooldown':["Crusier fire rate",1,0],
			'enemy2Spikes':['Fortress spikes',0,0],
			'enemy2Speed':['Fortress speed',0,0],
			'enemy2BulletSpeed':['Fortress Bullet speed',0,0],
			'enemy2Spin':['Fortress spin speed',1,1],
			'enemy2FireCooldown':['Fortress fire rate',1,0],
			'enemy3Speed':['enemy3 speed',0,0],
			'enemy3Delay':['enemy3 explosion delay',1,1],
			'enemy3ExplosionSize':['enemy3 explosion size',0,0]
			}
			
		# vairableName:[common name,discription,cant be with,isUpside]
		const specialUpgrades={
			'shotgun':['Shotgun','Shoot 5 bullets at once with a limited range and 1/2 fire rate',['dash','shotgun']],
			'dash':['Dash',"Dash through enemyies to deal damage and have double health but, you can't shoot",['dash','shotgun']],
			'laser':['Laser','Shoot a laser instead of a gun. Laser requires at least 1 second to charge up and shoots for as long as you charged it with a maximum of 3 seconds']}
		#var CSU=specialUpgrades.keys().filter(func(y): return not specialUpgrades[y][2].any(func(z):return z in specialUpgrades))
		if x==2 and specialUpgrade=='none' and randi_range(0,4)==0 and roundNumber>2:
			var upside=specialUpgrades.keys().pick_random()
			card.self_modulate=Color(1,0,0)
			card.get_node('Upsides').text=specialUpgrades[upside][0]
			card.get_node('Downsides').text=specialUpgrades[upside][1]
			card.get_node('Downsides').add_theme_color_override('font_color',Color(1,1,1))
			card.get_node('Downsides').position.y-=13
			if upside=='laser':card.get_node('Downsides').add_theme_font_size_override('font_size',20)
			card.set_meta('Special',upside)
			if upside=='dash':card.set_meta('Powers',[['playerHealth',2]])
		else:
			var upside=stats.keys().pick_random()
			while (upside=='enemy2Spikes' and upgradeStats['enemy2Spikes']<2) or (upside in ['playerSpeed','playerBulletSpeed'] and upgradeStats[upside]>1000) or ('enemy2' in upside and roundNumber<=0) or ('enemy3' in upside and roundNumber<=3):upside=stats.keys().pick_random()
			const powers=[[0.9,1.1],[0.8,1.25],[0.67,1.5],[0.5,2],[0.4,2.5]]
			var upsidePower=x+randi_range(1,2)
			card.get_node("Upsides").text='x'+str(powers[upsidePower][stats[upside][2]])+' '+stats[upside][0]
			var downside=upside
			while downside==upside or ('speed' in downside and upgradeStats[downside]>1000 and downside not in ['playerSpeed','playerBulletSpeed']) or ('enemy2' in downside and roundNumber<=0) or ('enemy3' in downside and roundNumber<=2):downside=stats.keys().pick_random()
			var downsidePower=upsidePower-randi_range(0,1)
			card.get_node("Downsides").text='x'+str(powers[downsidePower][stats[downside][2]*-1+1])+' '+stats[downside][0]
			card.set_meta('Powers',[[upside,powers[upsidePower][stats[upside][1]]],[downside,powers[downsidePower][stats[downside][1]*-1+1]]])
		card.position=Vector2(screen_size.x/2-432+288*x,screen_size.y/2-168)
		card.get_node('Button').pressed.connect(card_clicked.bind(card))
		background.add_child(card)
	add_child(background)

func card_clicked(card):
	var special=card.get_meta('Special')
	var powers=card.get_meta('Powers',[])
	if special:
		#playTestUpgrades.append(special)
		specialUpgrade = special
	#else:playTestUpgrades.append(powers)
	for x in powers:
		upgradeStats[x[0]]*=x[1]
	card.get_parent().queue_free()
	roundNumber+=1
	$RoundLabel.text='Round: '+str(roundNumber+1)
	$RoundLabel.show()
	lastPlayerPos=$Player.position
	$ResetPlayerTimer.start()
	await $ResetPlayerTimer.timeout
	$RoundLabel.hide()
	start_round()


func _on_player_death():
	$DeathScreen/Score.text='Score: '+str(roundNumber)
	$AnimationPlayer.play('Show Death Screen')
	for node in get_children():
		if node.get_meta('bullet', false):node.queue_free()
	
func goReset():
	get_node('DeathScreen/Button').release_focus()
	for node in get_children():
		if node.get_meta('enemy', false) or node.get_meta('bullet', false):node.queue_free()
	$DeathScreen.modulate=Color(1,1,1,0)
	lastPlayerPos=$Player.position
	$ResetPlayerTimer.start()
	await $ResetPlayerTimer.timeout
	start_game()

func _on_start_screen_start():
	start_game()

func boss_process(delta):
	if bossExists:
		#Image i make an entire boss fight right before the jam is done. (lol)
		for node in bossNodes:
			node.progress+=bossSpeed*delta
			node.get_node('Area2D').rotation+=PI*delta

func boss_hit(area,damage=1):
	#print(damage)
	bossHealth-=damage
	if not area.pierce:area.queue_free()
	if bossHealth<=0:
		for x in bossNodes:
			x.queue_free()
		on_enemy_death()
		bossExists=false
		$BossHealthBar.hide()
	elif bossHealth<=bossMaxHealth*0.25:$BossHealthBar.tint_progress=Color(1,0,0)
	elif bossHealth<=bossMaxHealth*0.5:$BossHealthBar.tint_progress=Color(1,1,0)
	else:$BossHealthBar.tint_progress=Color(0,1,0)
	$BossHealthBar.value=bossHealth


func _on_boss_shoot_timer_timeout():
	if bossExists:
		if bossNodes[2].position.x<100 or bossNodes[0].position.x>1052:
			for spike in bossSpikes:
				var bullet=bullet2Scene.instantiate()
				bullet.position=spike.get_parent().get_parent().position+spike.position.rotated(spike.get_parent().rotation)
				bullet.rotation=spike.rotation+spike.get_parent().rotation+spike.get_parent().get_parent().rotation
				bullet.move=Vector2(upgradeStats['enemy2BulletSpeed'],0).rotated(spike.rotation+spike.get_parent().rotation+spike.get_parent().get_parent().rotation+PI/2)
				add_child(bullet)
		elif bossNodes[0].position.y<100:
			for spike in bossSpikes:
				var bullet=bullet1Scene.instantiate()
				bullet.position=spike.get_parent().get_parent().position+spike.position.rotated(spike.get_parent().rotation)
				bullet.linear_velocity=Vector2(0,upgradeStats['enemy1BulletSpeed'])
				add_child(bullet)
		else:
			for spike in bossSpikes:
				var bullet=enemy3.instantiate()
				bullet.position=spike.get_parent().get_parent().position+spike.position.rotated(spike.get_parent().rotation)
				bullet.exploading=true
				bullet.lastRotation=PI/2
				bullet.scale=(Vector2(upgradeStats['enemy3ExplosionSize']*0.5/180,upgradeStats['enemy3ExplosionSize']*0.5/180))
				bullet.projectile=true
				bullet.get_node('ExplosionTimer').wait_time=upgradeStats['enemy3Delay']
				#bullet.get_node('ExplosionCollision').shape.radius=100
				#bullet.get_node('Explosion').scale=Vector2(0.5,0.5)
				bullet.velocity=Vector2(0,-randf_range(200,600))
				add_child(bullet)
				bullet.get_node('ExplosionTimer').start()
