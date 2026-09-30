extends Node2D

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var board_size: int
var cell_size: int
var grid_pos: Vector2i
var grid_data: Array
var player: int
var temp_marker
var player_panel_pos: Vector2i
var row_sum: int
var col_sum: int
var diag1_sum: int
var diag2_sum: int
var winner: int
var moves: int

func _ready():
	board_size = $Board.texture.get_width()
	cell_size = floori(float(board_size) / 3.0)
	player_panel_pos = $PlayerLabel.get_position()
	new_game()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x < board_size:
				grid_pos = Vector2i(event.position / cell_size)
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					create_marker(player, grid_pos * cell_size + Vector2i(floori(cell_size / 2.0), floori(cell_size / 2.0)))
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("Result").text = "Circle Won!"
						elif winner == -1:
							$GameOverMenu.get_node("Result").text = "Cross Won!"
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu.get_node("Result").text = "Draw!"
					player *= -1
					temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2i(cell_size - 50, cell_size - 5), true)

func new_game():
	moves = 0
	player = 1
	winner = 0
	grid_data = [
		[0, 0, 0], 
		[0, 0, 0], 
		[0, 0, 0]
		]
	row_sum = 0
	col_sum = 0
	diag1_sum = 0
	diag2_sum = 0
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	create_marker(player, player_panel_pos + Vector2i(cell_size - 50, cell_size - 5), true)
	$GameOverMenu.hide()
	get_tree().paused = false

func create_marker(marker_player, marker_position, temp = false):
	if marker_player == 1:
		var circle = circle_scene.instantiate()
		circle.position = marker_position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = marker_position
		add_child(cross)
		if temp: temp_marker = cross

func check_win():
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diag1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diag2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		
		if row_sum == 3 or col_sum == 3 or diag1_sum == 3 or diag2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diag1_sum == -3 or diag2_sum == -3:
			winner = -1
			
	return winner

func _on_game_over_menu_restart():
	new_game()
