extends Control

@export var boot_panel : Control
@export var auth_panel : Control
var load_database : CharacterDataLoader

func _on_submit_sign_in_button_3_pressed():
    var peer = ENetMultiplayerPeer.new()
    peer.create_client('127.0.0.1', 8082)
    multiplayer.multiplayer_peer = peer
    boot_panel.visible = false
    auth_panel.visible = true
    queue_free()

func _on_submit_sign_in_button_4_pressed():
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(8082, 5)
    multiplayer.multiplayer_peer = peer
    boot_panel.visible = false
    auth_panel.visible = false
    load_database = CharacterDataLoader.new()
    await load_database.fetch_characters_from_api(self)
    queue_free()
