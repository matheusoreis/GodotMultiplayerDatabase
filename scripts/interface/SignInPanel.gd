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


# var ConnectionStatusEnum = preload('res://scripts/utils/enums/auth/auth_enum.gd').new()
var SignInModelLocal: Script = preload('res://scripts/utils/models/auth/sign_in_model.gd')


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
        sign_in_model.email = sign_in_email_line.text
        sign_in_model.password = sign_in_pass_line.text

        # Desabilita o botão de login para evitar que o usuário clique novamente
        sign_in_submit_button.disabled = true

        # Faz uma chamada RPC para a função request_sign_in no servidor (peer 1)
        _on_request_sign_in.rpc_id(1, sign_in_model.to_dict())
    else:
        print("O cliente não está conectado ao servidor")


# Esta função é chamada no servidor quando um cliente faz uma solicitação de login
@rpc('any_peer', 'call_remote', 'reliable')
func _on_request_sign_in(sign_in_model_dict: Dictionary):
    var sender_id = multiplayer.get_remote_sender_id()

    # Converte o dicionário de volta para um objeto SignInModel
    var sign_in_model = SignInModel.from_dict(sign_in_model_dict) as SignInModel

    # Define a URL, cabeçalhos e corpo da solicitação HTTP
    var url = api_endpoint + "/api/collections/users/auth-with-password"
    var headers_dict = {"Content-Type": "application/json"}
    var body = JSON.stringify(sign_in_model.to_dict())

    var http_request = HTTPRequest.new()
    self.add_child(http_request)

    # Converte o Dictionary de cabeçalhos para um PackedStringArray
    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

    var data = await http_request.request_completed as Array
    if data[0] != OK:
        print("Erro ao iniciar a solicitação HTTP: ", data[0])
    else:
        var response_code = data[1]
        var response_body = (data[3] as PackedByteArray).get_string_from_utf8()

        # Passa sender_id como um argumento para _on_request_sign_in_completed
        _on_request_sign_in_completed.rpc_id(sender_id, response_code, response_body)


@rpc("authority","reliable")
func _on_request_sign_in_completed(response_code: int, _response_body: String):

    # Se o código de resposta for 200, envia uma mensagem de sucesso para o cliente
    if response_code == 200:
        print("Autenticação bem-sucedida")

    # Se o código de resposta for diferente de 200, envia uma mensagem de erro para o cliente
    else:
        print("Falha na autenticação: " + str(response_code))

    # Reativa o botão de login
    sign_in_submit_button.disabled = false
