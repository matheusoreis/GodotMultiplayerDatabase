extends PanelContainer

@export_category('SignIn')
@export var sign_in_panel : PanelContainer
@export var sign_in_email_line : LineEdit
@export var sign_in_pass_line : LineEdit
@export var sign_in_submit_button : Button

@export_category('RegExp')
var email_regex = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

@export_category('Backend')
@export var api_endpoint : String

var MyHttpClient = preload('res://scripts/utils/http.gd')
var http_client = MyHttpClient.new()

func _ready():
    add_child(http_client)

func _on_sign_in_line_text_changed(_new_text: String) -> void:
    var regex = RegEx.new()
    regex.compile(email_regex)

    var email_is_valid = regex.search(sign_in_email_line.text) != null
    var password_is_valid = sign_in_pass_line.text.length() > 6

    if email_is_valid and password_is_valid:
        sign_in_submit_button.disabled = false
    else:
        sign_in_submit_button.disabled = true

func _on_login_button_pressed() -> void:
    if sign_in_email_line.text.is_empty() and sign_in_email_line.text.is_empty():
        _show_alert(invalid_email_message, AlertButtonType.CONFIRM)
    else:
        if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
            _on_request_sign_in.rpc_id(1, sign_in_email_line.text, sign_in_password_line.text)
        else:
            _show_alert(client_disconnected_from_server, AlertButtonType.CONFIRM)

            @rpc('any_peer', 'call_remote', 'unreliable')
func _on_request_sign_in(sign_in_email: String, sign_in_password: String) -> void:
    sender_id = multiplayer.get_remote_sender_id()
    sign_in_submit_button.disabled = true

    var url = api_endpoint + '/api/collections/users/auth-with-password'
    var headers = {"Content-Type": "application/json"}
    var body = {
        "identity": sign_in_email,
        "password": sign_in_password,
    }

    http_client.post_request(url, headers, JSON.stringify(body))

    if not http_client.request_completed.is_connected(_on_request_sign_in_completed):
        http_client.request_completed.connect(_on_request_sign_in_completed)


@rpc('authority', 'reliable')
func _on_request_sign_in_completed(status: String, response_body: String, _method: int) -> void:
    http_client.request_completed.disconnect(_on_request_sign_in_completed)

    if status == "error":
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

        rpc_id(sender_id, '_on_request_sign_in_completed_response', ResponseType.ERROR, detailed_message)
        print("Sending response to peer ID: ", multiplayer.get_remote_sender_id())
    elif status != "success":
        rpc_id(sender_id, '_on_request_sign_in_completed_response', ResponseType.NONE, api_connection_failure_message)
        print("Sending response to peer ID: ", multiplayer.get_remote_sender_id())
    else:
        var json_parser = JSON.new()
        var response = json_parser.parse(response_body)
        if response == OK:
            var json_dict = json_parser.get_data()
            if json_dict is Dictionary:
                var token = json_dict.get("token", "")
                var record = json_dict.get("record", {})
                var id = record.get("id", "")
                var email = record.get("email", "")
                var access = record.get("access", "player")
                var banned = record.get("banned", false)

                token_manager.save_token(token)
                token_manager.save_id(id)
                token_manager.save_email(email)
                token_manager.save_access(access)
                token_manager.save_banned(banned)

        if token_manager.get_token() == "":
            rpc_id(sender_id, '_on_request_sign_in_completed_response', ResponseType.ERROR, api_parsing_error_message)
            print("Sending response to peer ID: ", multiplayer.get_remote_sender_id())
        else:
            rpc_id(sender_id, '_on_request_sign_in_completed_response', ResponseType.SUCCESS, api_authentication_success_message)
            print("Sending response to peer ID: ", multiplayer.get_remote_sender_id())

    sign_in_submit_button.disabled = false


@rpc('authority', 'reliable')
func _on_request_sign_in_completed_response(response: ResponseType, message: String) -> void:
    match response:
        ResponseType.SUCCESS:
            auth_panel.visible = false
            character_panel.visible = true
        ResponseType.ERROR:
            _show_alert(message, AlertButtonType.CONFIRM)
        ResponseType.NONE:
             _show_alert(message, AlertButtonType.GO_BACK)
