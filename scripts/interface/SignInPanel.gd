extends Control


@export_category('SignIn')
@export var sign_in_panel : Control
@export var sign_in_email_line : LineEdit
@export var sign_in_pass_line : LineEdit
@export var sign_in_submit_button : Button
@export var dlete_submit_button : Button


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

var character_data_loader = CharacterDataLoader.new()
var load_database : CharacterDataLoader


var received_characters : Array = []


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
        dlete_submit_button.disabled = true

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
func _on_request_sign_in_completed(response_code: int, response_body: String):

    if response_code != 200:
        var detailed_message = api_unknown_error_message
        var json_parser = JSON.new()
        var error = json_parser.parse(response_body)
        if error == OK:
            var json_dict = json_parser.get_data()
            if json_dict is Dictionary:

                if json_dict.has("message"):
                    detailed_message = json_dict["message"]

                if json_dict.has("data"):
                    for key in json_dict["data"].keys():
                        if json_dict["data"][key] is Dictionary and json_dict["data"][key].has("message"):
                            detailed_message += "\n" + json_dict["data"][key]["message"]
            else:
                detailed_message = api_parsing_error_message

        print(detailed_message)
    elif response_code == 200:
        var json_parser = JSON.new()
        var error = json_parser.parse(response_body)
        if error == OK:
            var json_dict = json_parser.get_data()
            if json_dict is Dictionary:
                var sign_in_response = SignInResponseModel.from_dict(json_dict)
                print("Token: ", sign_in_response.token)
                print("Record: ", sign_in_response.record)

                var user_id = sign_in_response.record["id"]
                server_node.request_characters.rpc_id(1, user_id)

                dlete_submit_button.disabled = false

            else:
                print(api_parsing_error_message)
        else:
            print(api_parsing_error_message)
    else:
        print(api_connection_failure_message)

    # Reativa o botão de login
    sign_in_submit_button.disabled = false


@rpc("authority","reliable")
func send_characters(character_dicts: Array):
    for character_dict in character_dicts:
        var character = CharacterModel.from_dict(character_dict)
        print("Personagem: ", character.name)


@rpc("authority","reliable")
func confirm_delete_character(character_id: String) -> void:
    pass


@rpc("authority","reliable")
func receive_characters(character_dicts: Array) -> void:
    received_characters.clear()
    for character_dict in character_dicts:
        received_characters.append(character_dict)


func _on_submit_sign_in_button_2_pressed() -> void:
    if received_characters.size() > 0:
        var user_id = received_characters[0]["user"]
        var character_id = received_characters[0]["id"]
        server_node.request_delete_character.rpc_id(1, user_id, character_id)
        received_characters.pop_front()
    else:
        print("Nenhum personagem recebido para deletar.")

