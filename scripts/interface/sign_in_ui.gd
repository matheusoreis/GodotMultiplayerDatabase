extends Control


@export_category('SignIn')
@export var sign_in_panel : Control
@export var sign_in_email_line : LineEdit
@export var sign_in_pass_line : LineEdit
@export var sign_in_submit_button : Button


@export_category('RegExp')
var email_regex = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"


@export_category('Backend')
@export var api_endpoint : String = 'http://127.0.0.1:8090'
@export var api_unknown_error_message : String = 'Unknown error!'
@export var api_parsing_error_message : String = 'Error parsing server response!'
@export var api_connection_failure_message : String = 'Failed to connect to the api server. Please check your internet connection and try again!'
@export var api_authentication_success_message : String = 'User successfully authenticated to the api server!'
@export var api_registration_success_message : String = 'User successfully registered on the api server!'


@export var server_node : Node
@export var character_ui: Control

var character_data_loader = CharacterDataLoader.new()
var load_database : CharacterDataLoader


func _on_sign_in_line_text_changed(_new_text: String) -> void:
    var regex = RegEx.new()
    regex.compile(email_regex)

    var email_is_valid = regex.search(sign_in_email_line.text) != null
    var password_is_valid = sign_in_pass_line.text.length() > 6

    if email_is_valid and password_is_valid:
        sign_in_submit_button.disabled = false
    else:
        sign_in_submit_button.disabled = true


# Esta função é chamada quando o botão de envio de login é pressionado
func _on_submit_sign_in_button_pressed() -> void:
    # Verifica se o peer está conectado ao servidor
    if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:

        # Cria uma nova instância do modelo de autenticação
        var sign_in_model = SignInModel.new(sign_in_email_line.text, sign_in_pass_line.text) as SignInModel

        # Desabilita o botão de login para evitar que o usuário clique novamente
        sign_in_submit_button.disabled = true

        print(sign_in_model.to_dict())

        # Faz uma chamada RPC para a função request_sign_in no servidor (peer 1)
        server_node.request_sign_in.rpc_id(1, sign_in_model.to_dict())
    else:
        print("O cliente não está conectado ao servidor")


@rpc("authority","reliable")
func on_request_sign_in_completed(success: bool, response: Dictionary):
    if success:
        var response_model = SignInResponseModel.from_dict(response)
        print("Login bem-sucedido")
        character_ui.set_user_id(response_model.record.id)
        sign_in_panel.visible = false
        character_ui.visible = true
        print("Token: ", response_model.token)
        print("ID do usuário: ", response_model.record.id)
    else:
        var error_response = ErrorModel.from_dict(response)
        print("Erro ao fazer login: ", error_response.message)

    # Reativa o botão de login
    sign_in_submit_button.disabled = false
