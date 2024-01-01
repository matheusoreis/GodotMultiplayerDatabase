extends RefCounted


class_name AccountDatabase


var api_endpoint : String


# Inicializa a classe com o endpoint da API.
func initialize(parent: Node, apiEndpoint: String):
    self.api_endpoint = apiEndpoint


# Autentica um usuário na API e retorna um dicionário com os dados de resposta.
# @param parent: O nó pai ao qual o HTTPRequest será adicionado.
# @param signInDict: Um dicionário contendo as informações de login do usuário.
func sign_in(parent: Node, signInDict: Dictionary) -> Dictionary:
    var sign_in_model = SignInModel.from_dict(signInDict) as SignInModel

    # Define a URL para a solicitação HTTP
    var url = api_endpoint + "/api/collections/users/auth-with-password"

    # Define os cabeçalhos para a solicitação HTTP
    var headers_dict = {"Content-Type": "application/json"}

    # Converte o objeto SignInModel em uma string JSON para o corpo da solicitação HTTP
    var body = JSON.stringify(sign_in_model.to_dict())

    # Cria um novo objeto HTTPRequest e o adiciona como filho do nó pai
    var http_request = HTTPRequest.new()
    parent.add_child(http_request)

    # Converte o dicionário de cabeçalhos em um PackedStringArray
    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    # Inicia a solicitação HTTP
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

    # Aguarda a conclusão da solicitação HTTP
    var data = await http_request.request_completed as Array

    # Verifica se a solicitação HTTP foi iniciada com sucesso
    if data[0] != OK:
        print("Erro ao iniciar a solicitação HTTP: ", data[0])
        return ErrorModel.new().to_dict()
    else:
        # Converte a resposta da solicitação HTTP em uma string
        var response_body = (data[3] as PackedByteArray).get_string_from_utf8()

        # Converte a string de resposta em um dicionário
        var response = JSON.parse_string(response_body)

        # Verifica o código de status da resposta
        if data[1] == 200:
            var sign_in_response = SignInResponseModel.from_dict(response) as SignInResponseModel
            return sign_in_response.to_dict()
        else:
            var error = ErrorModel.from_dict(response) as ErrorModel
            var detailed_message = "Código de erro: " + str(error.code) + "\nMensagem: " + error.message
            if error.data:
                for key in error.data.keys():
                    detailed_message += "\n" + key + ": " + error.data[key]["message"]
            print(detailed_message)
            return error.to_dict()

    return ErrorModel.clean().to_dict()
