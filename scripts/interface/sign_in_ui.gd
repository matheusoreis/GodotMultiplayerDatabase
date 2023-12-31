extends Control


@export_category('SignIn')
@export var sign_in_panel : Control
@export var sign_in_email_line : LineEdit
@export var sign_in_pass_line : LineEdit
@export var sign_in_submit_button : Button


@export_category('RegExp')
var email_regex = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"


@export_category('UI')
@export var character_ui: Control
@export var server_node : Node


# Função para validar o email e a senha
func validate_credentials() -> bool:
    # Cria um novo objeto RegEx
    var regex = RegEx.new()
    # Compila a expressão regular para validar o email
    regex.compile(email_regex)

    # Verifica se o email é válido
    var email_is_valid = regex.search(sign_in_email_line.text) != null
    # Verifica se a senha tem mais de 6 caracteres
    var password_is_valid = sign_in_pass_line.text.length() > 6

    # Retorna verdadeiro se o email e a senha são válidos, falso caso contrário
    return email_is_valid and password_is_valid


# Esta função é chamada quando o usuário altera o texto dos LineEdits
func _on_sign_in_line_text_changed(_newText: String) -> void:
    # Se o email e a senha são válidos, o botão de envio é habilitado
    if validate_credentials():
        sign_in_submit_button.disabled = false
    # Se o email ou a senha não são válidos, o botão de envio é desabilitado
    else:
        sign_in_submit_button.disabled = true


# Esta função é chamada quando o usuário pressiona Enter no campo de senha
func _on_password_sign_in_line_text_submitted(_newText: String) -> void:
    # Se o email e a senha são válidos, chama a função que é executada quando o botão de envio é pressionado
    if validate_credentials():
        _on_submit_sign_in_button_pressed()


# Esta função é chamada quando o botão de envio de login é pressionado
func _on_submit_sign_in_button_pressed() -> void:
    # Verifica se o peer está conectado ao servidor
    if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:

        # Cria uma nova instância do modelo de autenticação
        var sign_in_model = SignInModel.new(sign_in_email_line.text, sign_in_pass_line.text) as SignInModel

        # Desabilita o botão de login para evitar que o usuário clique novamente
        sign_in_submit_button.disabled = true

        # Faz uma chamada RPC para a função request_sign_in no servidor (peer 1)
        server_node.request_sign_in.rpc_id(1, sign_in_model.to_dict())
    else:
        print("O cliente não está conectado ao servidor")


# Esta função é chamada quando a solicitação de login é concluída
@rpc("authority","reliable")
func on_request_sign_in_completed(success: bool, response: Dictionary):
    # Se a solicitação de login foi bem-sucedida
    if success:
        var response_model = SignInResponseModel.from_dict(response) as SignInResponseModel
        print("Login bem-sucedido")

        # Define o ID do usuário na interface do usuário do personagem
        character_ui.set_user_id(response_model.record.id)

        # Esconde o painel de login e mostra a interface de personagens do usuário
        sign_in_panel.visible = false
        character_ui.visible = true
    # Se a solicitação de login falhou
    else:
        var error_response = ErrorModel.from_dict(response) as ErrorModel
        print("Erro ao fazer login: ", error_response.message)

    # Reativa o botão de login
    sign_in_submit_button.disabled = false
