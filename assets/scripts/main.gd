extends Node2D
@export var enemy1:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_spawn_enemy1"):spawn_enemy1()

func spawn_enemy1():
	var enemy=enemy1.instantiate()
	enemy.position=Vector2(-16,0)
	add_child(enemy)
