extends PanelContainer


@export_category('SignIn')
@export var sign_in_panel : PanelContainer
@export var sign_in_email_line : LineEdit
@export var sign_in_pass_line : LineEdit
@export var sign_in_submit_button : Button


@export_category('RegExp')
var email_regex = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"


@export_category('Backend')
@export var api_endpoint : String = 'http://127.0.0.1'


# var ConnectionStatusEnum = preload('res://scripts/utils/enums/auth/auth_enum.gd').new()
var SignInModel: Script = preload('res://scripts/utils/models/auth/sign_in_model.gd')


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

        # Faz uma chamada RPC para a função request_sign_in no servidor (peer 1)
        _on_request_sign_in.rpc_id(1, sign_in_model.to_dict())
    else:
        print("O cliente não está conectado ao servidor")


# Esta função é chamada no servidor quando um cliente faz uma solicitação de login
@rpc('any_peer', 'call_remote', 'reliable')
func _on_request_sign_in(sign_in_model_dict: Dictionary):
    var sender_id = multiplayer.multiplayer_peer.get_unique_id()
    
    # Desabilita o botão de login para evitar que o usuário clique novamente
    sign_in_submit_button.disabled = true
    
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

        # Faz uma chamada RPC para a função _on_request_sign_in_completed com o sender_id e a resposta HTTP como argumentos
        _on_request_sign_in_completed.rpc_id(sender_id, response_code, response_body)

    # Reativa o botão de login
    sign_in_submit_button.disabled = false


@rpc("authority", "reliable")
func _on_request_sign_in_completed(sender_id: int, response_code: int, _response_body: String):

    # Se o código de resposta for 200, envia uma mensagem de sucesso para o cliente
    if response_code == 200:
        _on_sign_in_response.rpc_id(sender_id, true, "Autenticação bem-sucedida")
    # Se o código de resposta for diferente de 200, envia uma mensagem de erro para o cliente
    else:
        _on_sign_in_response.rpc_id(sender_id, false, "Erro na autenticação: " + str(response_code))

    # Reativa o botão de login
    sign_in_submit_button.disabled = false


# Esta função é chamada quando o cliente recebe a resposta do servidor
@rpc("authority", "reliable")
func _on_sign_in_response(success: bool, message: String):
    # Se a autenticação foi bem-sucedida, imprime uma mensagem de sucesso
    if success:
        print("Autenticação bem-sucedida")
    # Se a autenticação falhou, imprime uma mensagem de erro
    else:
        print("Falha na autenticação: " + message)


func _on_submit_sign_in_button_3_pressed():
    var peer = ENetMultiplayerPeer.new()
    peer.create_client('127.0.0.1', 8082)
    multiplayer.multiplayer_peer = peer
    print('cliente nessa porra')

func _on_submit_sign_in_button_4_pressed():
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(8082, 5)
    multiplayer.multiplayer_peer = peer
    sign_in_panel.visible = false
