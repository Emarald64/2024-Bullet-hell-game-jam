extends ColorRect
signal start

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass


func _on_help_pressed():
	$"Help menu".show()


func _on_ok_pressed():
	$"Help menu".hide()


func _on_start_pressed():
	start.emit()
	queue_free()
