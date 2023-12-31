extends Control

@export_category('Backend')
@export var endpoint : String = 'http://127.0.0.1:8090'

@export var character_ui : Node


var load_database : CharacterDataLoader


func _on_visibility_changed() -> void:
    load_database = CharacterDataLoader.new()
    load_database.initialize(self)


@rpc('any_peer', 'call_remote', 'reliable')
func request_characters(user_id: String):
    var sender_id = multiplayer.get_remote_sender_id()
    var characters = load_database.get_characters_for_user(user_id)
    var character_dicts = []
    for character in characters:
        character_dicts.append(character.to_dict())
    character_ui.receive_characters.rpc_id(sender_id, character_dicts)


@rpc('any_peer', 'call_remote', 'reliable')
func request_delete_character(user_id: String, character_id: String) -> void:
    var sender_id = multiplayer.get_remote_sender_id()
    load_database.delete_character_from_api(self, user_id, character_id)
    character_ui.confirm_delete_character.rpc_id(sender_id, character_id)

@rpc('any_peer', 'call_remote', 'reliable')
func request_create_character(user_id: String, character_name: String) -> void:
    var sender_id = multiplayer.get_remote_sender_id()
    var new_character = await load_database.create_character_on_api(self, user_id, character_name)
    if new_character != null and not new_character.is_empty():
        character_ui.confirm_create_character.rpc_id(sender_id, new_character)
