extends SpringArm3D
class_name PlayerCamera

@export var y_offset: float = 1.061

@onready var player: Player = NodeGlobals.get_ancestor_of_type(self, Player)
@onready var camera: Camera3D = %Camera

var controller_camera_input = Vector2.ZERO

var fov: float:
	get: return camera.fov
	set(x): camera.fov = x

func _unhandled_input(event) -> void:
	if not player.control_style:
		return
	
	# Orbital Camera (Mouse)
	if event is InputEventMouseMotion and player.state == Player.PlayerState.WALK and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * Globals.SENSITIVITY * SaveFileService.settings_file.camera_sensitivity)
		rotation.x -= event.relative.y * Globals.SENSITIVITY * SaveFileService.settings_file.camera_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	# Orbital Camera (Controller)
	if event is InputEventJoypadMotion and player.state == Player.PlayerState.WALK:
		var dead_zone = 0.2  # Adjust if needed
		var axis_value = event.axis_value

		# Ignore small joystick movements
		if abs(axis_value) < dead_zone:
			axis_value = 0  

		match event.axis:
			JOY_AXIS_RIGHT_X:  # Yaw (Left/Right)
				controller_camera_input.x = axis_value
			JOY_AXIS_RIGHT_Y:  # Pitch (Up/Down)
				controller_camera_input.y = axis_value
	

func _process(_delta: float) -> void:
	global_position = player.get_global_transform_interpolated().origin + Vector3(0, y_offset, 0)
	var sensitivity = SaveFileService.settings_file.camera_sensitivity * 175  # Adjust speed as needed

	# Apply continuous rotation based on joystick input
	rotation_degrees.y -= controller_camera_input.x * sensitivity * _delta
	var new_pitch = rotation_degrees.x - (controller_camera_input.y * sensitivity * _delta)
	rotation_degrees.x = clamp(new_pitch, -89, 89)

func make_current() -> void:
	camera.make_current()
