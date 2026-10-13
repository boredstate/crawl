extends TextureRect

const TILE := 32

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var step := Vector2.ZERO
	match event.keycode:
		KEY_RIGHT, KEY_D:
			step = Vector2(TILE, 0)
		KEY_LEFT, KEY_A:
			step = Vector2(-TILE, 0)
		KEY_DOWN, KEY_S:
			step = Vector2(0, TILE)
		KEY_UP, KEY_W:
			step = Vector2(0, -TILE)
		KEY_SPACE:
			step = Vector2.ZERO
		_:
			return
	get_viewport().set_input_as_handled()
	get_parent().try_step(step)
