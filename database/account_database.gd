extends RefCounted


class_name AccountDatabase


var api_endpoint : String


# Inicializa a classe com o endpoint da API.
func initialize(parent: Node, endpoint: String):
    self.api_endpoint = endpoint


func sign_in(parent: Node, sign_in_dict: Dictionary) -> Dictionary:

    var sign_in_model = SignInModel.from_dict(sign_in_dict)

    var url = api_endpoint + "/api/collections/users/auth-with-password"
    var headers_dict = {"Content-Type": "application/json"}
    var body = JSON.stringify(sign_in_model.to_dict())

    var http_request = HTTPRequest.new()
    parent.add_child(http_request)

    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

    var data = await http_request.request_completed as Array
    if data[0] != OK:
        print("Erro ao iniciar a solicitação HTTP: ", data[0])
        return ErrorModel.new().to_dict()
    else:
        var response_body = (data[3] as PackedByteArray).get_string_from_utf8()
        print(response_body)  # Adicione esta linha
        var response = JSON.parse_string(response_body)

        if data[1] == 200:
            var sign_in_response = SignInResponseModel.from_dict(response)
            print("SignInResponseModel criado com sucesso")
            return sign_in_response.to_dict()
        elif data[1] == 400 or data[1] == 403:
            var error = ErrorModel.from_dict(response)
            var detailed_message = "Falha ao criar o registro: " + error.message
            if error.data.has("message"):
                detailed_message += "\n" + error.data["message"]
            print(detailed_message)
            return ErrorModel.new().to_dict()

    return ErrorModel.new().to_dict()
