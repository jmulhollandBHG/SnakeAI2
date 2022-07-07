extends Node
onready var obstacles = get_node("Obstacles")
var snake
var window_border
var leftP
var rightP 
var upP
var downP
var apple_pos
var appleMoves = 0
var applePrio = .244
func _ready():
	reset_variables()
	window_border = OS.get_window_size()
	var classLoad = load("res://Scripts/Snake.gd")
	snake = classLoad.new()
	draw_apple()
	$apple.visible = true
	

	

func get_random_pos_for_apple():
	randomize()
	var x= (randi() % 20) * snake.width
	var y= (randi() % 20) * snake.width
	apple_pos = Vector2(x,y)
	return Vector2(x,y)		
func get_random_pos_for_obstacle():
	randomize()
	var x= (randi() % 20) * snake.width
	var y= (randi() % 20) * snake.width
	return Vector2(x,y)			
func draw_apple():
	var new_rand_pos = get_random_pos_for_apple()
	for block in snake.body:
		if block == new_rand_pos:
			new_rand_pos = get_random_pos_for_apple()
			continue
		if(block == snake.body[snake.body.size()-1]):
			$apple.position = new_rand_pos
func draw_obstacle():
	for child in obstacles.get_children():
		var new_rand_pos = get_random_pos_for_obstacle()
		for block in snake.body:
			if block == new_rand_pos:
				new_rand_pos = get_random_pos_for_apple()
				continue
			if(block == snake.body[snake.body.size()-1]):
				child.rect_global_position = new_rand_pos		
		


func draw_snake():
	if(snake.body.size() > $snake.get_child_count()):
		var lastChilde = $snake.get_child($snake.get_child_count()-1).duplicate()
		lastChilde.name = "body " + str($snake.get_child_count())
		$snake.add_child(lastChilde)	
	for index in range(0,snake.body.size()):
		$snake.get_child(index).rect_position = snake.body[index]

func is_apple_colide():
	if(snake.body[0] == $apple.position):
		return true
	return false 
	
func calculateToApple(priority):
	if(abs(apple_pos.x - snake.body[0].x) < abs(apple_pos.y - snake.body[0].y)):
		if(apple_pos.y > snake.body[0].y):
			downP +=priority
		else:
			upP +=priority
		if(apple_pos.x > snake.body[0].x):
			rightP += (priority/2)
		else:
			leftP += (priority/2)
	else:
		if(apple_pos.x > snake.body[0].x):
			rightP +=priority
		else:
			leftP +=priority
		if(apple_pos.y > snake.body[0].y):
			downP +=(priority/2)
		else:
			upP +=(priority/2)
			
func checkSafety():
	applePrio += .0008
	$Timer.wait_time -= .000111
	print(applePrio)
	calculateToApple(applePrio)
	var inWhile = true
	var count = 1
	while(inWhile):
		if(count > 4):
			inWhile = false
		if(count == 1):
			snake.direction = Vector2(snake.width,0)
		elif(count ==2):
			snake.direction = Vector2(-snake.width,0)
		elif(count == 3):
			snake.direction = Vector2(0,snake.width)
		elif(count ==4):
			snake.direction = Vector2(0,-snake.width)
		for block in snake.body.slice(1,snake.body.size()):
			if(snake.body[0] + snake.direction == block || snake.body[0] + snake.direction == snake.body[0] || ((snake.body[0] + snake.direction + Vector2(snake.width,0) == block) && (snake.body[0] + snake.direction + Vector2(-snake.width,0) == block) && (snake.body[0] + snake.direction + Vector2(0,snake.width) == block) && (snake.body[0] + snake.direction + Vector2(0,-snake.width) == block))):
				evaluateDeath(snake.direction)
		for child in obstacles.get_children():
			if(snake.body[0]+ snake.direction == child.rect_global_position):
				evaluateDeath(snake.direction)
		if((snake.body[0] + snake.direction).x < 0 || (snake.body[0] + snake.direction).x > window_border.x - snake.width):
			evaluateDeath(snake.direction)
		if((snake.body[0] + snake.direction).y < 0 || (snake.body[0] + snake.direction).y > window_border.y - snake.width):
			evaluateDeath(snake.direction)
		count+=1
	move()
func safeDirection(dir, array):
	var i = 0
	while i < (snake.body.size() - array.size()):
		if(snake.body[0] + dir == snake.body[i]):
			return false
	for block in array:
		if(snake.body[0] + dir == block || snake.body[0] + snake.direction == snake.body[0]):
			return false
	if((snake.body[0] + dir).x < 0 || (snake.body[0] + dir).x > window_border.x - snake.width):
		return false
	if((snake.body[0] + dir).y < 0 || (snake.body[0] + dir).y > window_border.y - snake.width):
		return false
	return true
		
		
func move():
	var dir = findGreatest()
	if(dir == "UP"):
		snake.direction = Vector2(0,-snake.width)
	elif(dir == "DOWN"):
		snake.direction = Vector2(0,snake.width)
	elif(dir == "RIGHT"):
		snake.direction = Vector2(snake.width,0)
	elif(dir == "LEFT"):
		snake.direction = Vector2(-snake.width,0)
func findGreatest():
	if(appleMoves >= 900):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var num = rng.randi_range(0,3)
		if(num == 0):
			return "UP"
		elif(num == 1):
			return "DOWN"
		elif(num == 2):
			return "LEFT"
		elif(num == 3):
			return "RIGHT"
		appleMoves = 0
	if(upP >= downP && upP >= leftP && upP >= rightP):
		return "UP"
	elif(downP >= upP && downP >= leftP && downP >= rightP):
		return "DOWN"
	elif(leftP >= downP && leftP >= upP && leftP >= rightP):
		return "LEFT"
	elif(rightP >= downP && rightP >= leftP && rightP >= upP):
		return "RIGHT"
func evaluateDeath(dir):
	var priority = 1.00
	if(snake.direction == Vector2(snake.width,0)):
		rightP -= priority
	elif(snake.direction == Vector2(-snake.width,0)):
		leftP -= priority
	elif(snake.direction == Vector2(0,snake.width)):
		downP -=priority
	elif(snake.direction == Vector2(0,-snake.width)):
		upP -=priority
func is_game_over():
	if(snake.body[0].x < 0 || snake.body[0].x > window_border.x - snake.width):
		return true
	elif(snake.body[0].y < 0 || snake.body[0].y > window_border.y - snake.width):
		return true
	if(snake.body.size() >= 3):
		for block in snake.body.slice(1,snake.body.size()):
			if(snake.body[0] == block):
				return true
	for child in obstacles.get_children():
		if(snake.body[0] == child.rect_global_position):
			return true
	
	return false
func reset_variables():
	upP = 0
	downP = 0
	rightP = 0
	leftP = 0
func _on_Timer_timeout():
	appleMoves+=1
	if is_game_over():
		get_tree().reload_current_scene()
	checkSafety()
	if(randi()%100+1 <=10):
		draw_obstacle()
	snake.move()
	reset_variables()
	draw_snake()
	if(is_apple_colide()):
		applePrio = .244
		$Timer.wait_time = .15
		appleMoves = 0
		$AudioStreamPlayer2D.playing = true
		draw_apple()
		snake.is_apple_colide = true
	
