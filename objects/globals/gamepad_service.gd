extends Node

# Sensitivity factor to adjust how fast the cursor moves
var cursor_speed := 10.0

func _process(delta):
	# Check if the gamepad button is pressed
	if Input.is_action_just_pressed("gamepad_left_click"):
		simulate_mouse_click(true)  # Press LMB

	if Input.is_action_just_released("gamepad_left_click"):
		simulate_mouse_click(false)  # Release LMB
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		return # Only move cursor if it's visible

	var move_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) # Adjust for controller index if needed
	var move_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	# Deadzone to prevent unwanted drift
	var deadzone = 0.15
	if abs(move_x) < deadzone:
		move_x = 0
	if abs(move_y) < deadzone:
		move_y = 0

	if move_x != 0 or move_y != 0:
		var mouse_pos = get_viewport().get_mouse_position()
		mouse_pos.x += move_x * cursor_speed
		mouse_pos.y += move_y * cursor_speed

		# Keep cursor within screen bounds
		mouse_pos.x = clamp(mouse_pos.x, 0, get_viewport().size.x)
		mouse_pos.y = clamp(mouse_pos.y, 0, get_viewport().size.y)

		# Move the cursor
		Input.warp_mouse(mouse_pos)

func simulate_mouse_click(pressed: bool):
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = get_viewport().get_mouse_position()
	get_viewport().push_input(event)
