extends CharacterBody2D


const SPEED = 300.0

@export var player := 1 :
    set(id):
        player = id
        # Give authority over the player input to the appropriate peer.
        $PlayerInput.set_multiplayer_authority(id)

@onready var input = $PlayerInput

func _process(delta: float) -> void:
    var velocity = Vector2.ZERO

    if Input.is_action_pressed('left'):
        velocity.x -= SPEED
    if Input.is_action_pressed('right'):
        velocity.x += SPEED
    if Input.is_action_pressed('down'):
        velocity.y += SPEED
    if Input.is_action_pressed('up'):
        velocity.y -= SPEED

    position += velocity * delta
