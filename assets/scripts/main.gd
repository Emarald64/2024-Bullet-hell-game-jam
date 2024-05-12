extends Node2D
@export var enemy1:PackedScene
@export var enemy2:PackedScene
var screen_size
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$Player.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_spawn_enemy1"):spawn_enemy1()
	if Input.is_action_just_pressed("debug_spawn_enemy2"):spawn_enemy2()

func spawn_enemy1():
	var enemy=enemy1.instantiate()
	enemy.position=Vector2(-16,0)
	add_child(enemy)

func spawn_enemy2():
	var enemy=enemy2.instantiate()
	enemy.position=Vector2(randi_range(40,screen_size.x-40),-32)
	enemy.move=Vector2([-150,150][randi_range(0,1)],150)
	add_child(enemy)
