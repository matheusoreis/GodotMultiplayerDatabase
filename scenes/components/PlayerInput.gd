extends MultiplayerSynchronizer

@export var direction := Vector2()
const SPEED = 300.0

func _ready():
    set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(delta: float) -> void:
    direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
