extends Control

@export_category('UI')
@export var server_ui: Control
@export var boot_ui: Control
@export var auth_ui: Control


@export_category('Client Configuration')
@export var host: String = '127.0.0.1'


@export_category('Server Configuration')
@export var port: int = 8082
@export var max_clients: int = 10

# Função chamada quando o botão de iniciar cliente é pressionado
func _on_start_client_button_pressed() -> void:
    # Cria um novo peer de multiplayer ENet
    var peer = ENetMultiplayerPeer.new()

    # Configura o peer para se conectar a um servidor
    peer.create_client(host, port)

    # Define o peer de multiplayer para o peer criado
    multiplayer.multiplayer_peer = peer

    # Altera a visibilidade dos painéis
    boot_ui.visible = false
    auth_ui.visible = true
    server_ui.visible = false

    # Libera o nó da tree
    queue_free()


# Função chamada quando o botão de iniciar servidor é pressionado
func _on_start_server_button_pressed() -> void:
    # Cria um novo peer de multiplayer ENet
    var peer = ENetMultiplayerPeer.new()

    # Configura o peer para criar um servidor
    peer.create_server(port, max_clients)

    # Define o peer de multiplayer para o peer criado
    multiplayer.multiplayer_peer = peer

    # Altera a visibilidade dos painéis
    boot_ui.visible = false
    auth_ui.visible = false
    server_ui.visible = true

    # Libera o nó da tree
    queue_free()
