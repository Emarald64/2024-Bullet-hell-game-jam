extends Node2D
@export var enemy1:PackedScene
@export var enemy2:PackedScene
var roundTick=0
var screen_size
var enemies={0:1,10:2}
var enemyCount:int
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$Player.start()
	$RoundTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_spawn_enemy1"):spawn_enemy1()
	if Input.is_action_just_pressed("debug_spawn_enemy2"):spawn_enemy2()

func start_round(round:int):
	$RoundTimer.start()
	enemyCount=len(enemies)

# round layout
# Dictonary with keys as times and values as enemy numbers
# times are in 0.1 seconds
# values are the enemy number
# call to start round $RoundTimer.start()

func spawnRound():
	if roundTick in enemies.keys():
		if enemies[roundTick]==1:spawn_enemy1()
		elif enemies[roundTick]==2:spawn_enemy2()
	roundTick+=1

func spawn_enemy1():
	var enemy=enemy1.instantiate()
	enemy.position=Vector2(-16,0)
	add_child(enemy)

func spawn_enemy2():
	var enemy=enemy2.instantiate()
	enemy.position=Vector2(randi_range(40,screen_size.x-40),-32)
	enemy.move=Vector2([-150,150][randi_range(0,1)],150)
	enemy.dead.connect()
	add_child(enemy)

func on_enemy_death():
	enemyCount-=1
	if enemyCount==0:
		
