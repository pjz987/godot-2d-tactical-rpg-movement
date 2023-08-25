# Represents a unit on the game board.
# The board manages the Unit's position inside the game grid.
# The unit itself is only a visual representation that moves smoothly in the game world.
# We use the tool mode so the `skin` and `skin_offset` below update in the editor.
@tool
class_name Unit
extends Path2D

# Preload the `grid.tres` resource you created in the previous part.
@export var grid: Resource = preload("res://GameBoard/grid.tres")
# Distance to which the unit can walk in cells.
# We'll use this to limit the cells the unit can move to.
@export var move_range := 6
# Texture representing the unit.
# With the `tool` mode, assigninga new texture to this property in the inspector will update the
# unit's sprite instantly.  See `set_skin()` below.
@export var skin: Texture:
	set = set_skin
# Our unit's skin is just a sprite in this demo and depending on its size, we need to offset it so
# the sprite aligns with the shadow.
@export var skin_offset := Vector2.ZERO:
	set = set_skin_offset
# The unit's move speed in pixels, when it's moving along a path.
@export var move_speed := 600.0

# Coordinates of the grid's cell the unit is on.
var cell := Vector2.ZERO:
	set = set_cell
# Toggles the "selected" animation on the unit.
var is_selected := false:
	set = set_is_selected

# Through its setter function, the `_is_walking` property toggles processing for this unit.
# See _`set_is_walking()` at the bottom of this code snippet.
var _is_walking := false:
	set = _set_is_walking

@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow_2d: PathFollow2D = $PathFollow2D


# When changing the `cell`'s value, we don't want to allow coordinates outside the grid, so we clamp
# them.
func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

# The `is_selected` property toggles playback of the "selected" animation.
func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

# Both setters below manipulate the unit's Sprite node.
# Here, we update the sprite's texture.
func set_skin(value: Texture) -> void:
	skin = value
	# Setter functions are called during the node's `_init()` callback, before they entered the
	# tree. At that point in time, the `_sprite` variable is `null`.  If so, we have to wait to
	# update the sprite's properties.
	if not _sprite:
		# The await keyword allows us to wait until the unit node's `_ready()` callback ended.
		# (Maybe? This was written for the yield keyword in Godot 3)
		await self.ready
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		await self.ready
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(value)
