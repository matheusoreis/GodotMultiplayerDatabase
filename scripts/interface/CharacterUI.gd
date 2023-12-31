extends Control

@export var character_ui : Control
@export var character_hbox: HBoxContainer
@export var server_ui : Control


var user_id : String
var received_characters : Array = []


func set_user_id(user: String) -> void:
    print(user)
    self.user_id = user
    print(user_id)


func _on_visibility_changed() -> void:
    print('user: ' + user_id)
    if visible:
        server_ui.request_characters.rpc_id(1, user_id)


@rpc("authority","reliable")
func send_characters(character_dicts: Array):
    for character_dict in character_dicts:
        var character = CharacterModel.from_dict(character_dict)
        print("Personagem: ", character.name)


@rpc("authority","reliable")
func confirm_delete_character(_character_id: String) -> void:
    pass


@rpc("authority","reliable")
func receive_characters(character_dicts: Array) -> void:
    for character_dict in character_dicts:
        if character_dict not in received_characters:
            received_characters.append(character_dict)
    create_buttons(received_characters)


func create_buttons(characters: Array) -> void:
    for character_dict  in characters:
        var character = CharacterModel.from_dict(character_dict)
        var button = Button.new() as Button
        button.name = character.id
        button.text = character.name
        button.pressed.connect(_on_character_button_pressed.bind(button))
        character_hbox.add_child(button)

func _on_character_button_pressed(button: Button) -> void:
    var character_id = button.name
    server_ui.request_delete_character.rpc_id(1, user_id, character_id)
    button.queue_free()
