extends Control


@export_category('Backend')
@export var api_endpoint: String = 'http://127.0.0.1:8090'
@export var api_token: String = ''


@export_category('Ui')
@export var character_ui: Control
@export var auth_ui: Control


var character_database: CharacterDataLoader
var account_database: AccountDatabase


# Inicializa o carregador de dados quando a visibilidade do nó muda
func _on_visibility_changed() -> void:
    account_database = AccountDatabase.new()
    character_database = CharacterDataLoader.new()

    account_database.initialize(self, api_endpoint)
    character_database.initialize(self, api_endpoint, api_token)


# Solicita o login de um usuário específico
@rpc('any_peer', 'call_remote', 'reliable')
func request_sign_in(sign_in_dict: Dictionary):
    # Obtém o ID do remetente
    var sender_id = multiplayer.get_remote_sender_id()

    # Solicita o login do usuário
    var response_dict = await account_database.sign_in(self, sign_in_dict)

    # Verifica o tipo do objeto de resposta
    if response_dict.has("token"):
        # Sucesso: Converte o dicionário de resposta em um modelo SignInResponseModel
        var response = SignInResponseModel.from_dict(response_dict)
        auth_ui.on_request_sign_in_completed.rpc_id(sender_id, true, response.to_dict())
    else:
        # Erro: Converte o dicionário de resposta em um modelo ErrorModel
        var error_response = ErrorModel.from_dict(response_dict)
        auth_ui.on_request_sign_in_completed.rpc_id(sender_id, false, error_response.to_dict())


# Solicita os personagens de um usuário específico
@rpc('any_peer', 'call_remote', 'reliable')
func request_characters(user_id: String):
    # Obtém o ID do remetente
    var sender_id = multiplayer.get_remote_sender_id()

    # Recupera os personagens do usuário
    var characters = character_database.get_characters_for_user(user_id)

    # Lista para armazenar os personagens como dicionários
    var character_dicts = []
    for character in characters:
        character_dicts.append(character.to_dict())

    # Envia os personagens para a interface do usuário
    character_ui.receive_characters.rpc_id(sender_id, character_dicts)


# Solicita a exclusão de um personagem
@rpc('any_peer', 'call_remote', 'reliable')
func request_delete_character(user_id: String, character_id: String) -> void:
    # Obtém o ID do remetente
    var sender_id = multiplayer.get_remote_sender_id()

    # Deleta o personagem da API
    character_database.delete_character_from_api(self, user_id, character_id)

    # Confirma a exclusão para a interface do usuário
    character_ui.confirm_delete_character.rpc_id(sender_id, character_id)


# Solicita a criação de um novo personagem
@rpc('any_peer', 'call_remote', 'reliable')
func request_create_character(user_id: String, character_name: String) -> void:
    # Obtém o ID do remetente
    var sender_id = multiplayer.get_remote_sender_id()

    # Cria um novo personagem na API
    var new_character = await character_database.create_character_on_api(self, user_id, character_name)

    # Verifica se o novo personagem foi criado com sucesso e não está vazio
    if new_character != null and not new_character.is_empty():
        # Confirma a criação para a interface do usuário
        character_ui.confirm_create_character.rpc_id(sender_id, new_character)
