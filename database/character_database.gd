extends RefCounted

# Classe CharacterDataLoader
# Esta classe é responsável por carregar dados de personagens de uma API.
class_name CharacterDataLoader


var api_endpoint : String
var api_token: String
var user_characters = {}


# Inicializa a classe com o endpoint da API e busca os personagens.
func initialize(parent: Node, endpoint: String, token: String):
    self.api_endpoint = endpoint
    self.api_token = token
    await fetch_characters_from_api(parent)


# Busca os personagens da API e armazena-os em um dicionário (memória do servidor).
# parent: O nó pai ao qual o objeto HTTPRequest será adicionado.
func fetch_characters_from_api(parent: Node):
     # Define a URL da API.
    var url = api_endpoint + "/api/collections/characters/records"

    # Define os cabeçalhos da requisição com o token necessário para a api validar.
    var headers_dict = {"Content-Type": "application/json", "token": api_token}

    # Cria um novo objeto HTTPRequest e o adiciona ao nó pai.
    var http_request = HTTPRequest.new()
    parent.add_child(http_request)

    # Converte o dicionário de cabeçalhos em um PackedStringArray.
    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    # Inicia a paginação na página 1.
    var page = 1
    var total_pages = 1

     # Faz requisições GET para cada página até que todas as páginas sejam buscadas.
    while page <= total_pages:
        http_request.request(url + "?page=" + str(page), headers, HTTPClient.METHOD_GET)
        var data = await http_request.request_completed as Array

        # Se a requisição falhar, imprime um erro e retorna.
        if data[0] != OK:
            print("Erro ao iniciar a solicitação HTTP: ", data[0])
            return
        else:
            # Se a requisição for bem-sucedida, processa a resposta.
            var response_body = (data[3] as PackedByteArray).get_string_from_utf8()
            print("Resposta da API: ", response_body)
            var response = JSON.parse_string(response_body)

            # Processa cada item na resposta.
            var items = response["items"]
            for item in items:
                var character = CharacterModel.from_dict(item)
                var user_id = character.user

                # Adiciona o personagem ao dicionário de personagens (memória do servidor).
                if user_id in user_characters:
                    user_characters[user_id].append(character.to_dict())
                else:
                    user_characters[user_id] = [character.to_dict()]

             # Atualiza o número total de páginas e avança para a próxima página.
            total_pages = response["totalPages"]
            page += 1


# Retorna uma lista de personagens para um usuário específico.
# @param user_id: O ID do usuário para o qual buscar os personagens.
func get_characters_for_user(user_id: String) -> Array:

    # Verifica se o user_id fornecido está presente no dicionário user_characters.
    if user_id in user_characters:
        # Inicializa uma lista para armazenar os personagens do usuário.
        var user_characters_list = []

        # Itera sobre os personagens do usuário.
        for character in user_characters[user_id]:
            # Adiciona o personagem à lista de personagens do usuário.
            user_characters_list.append(CharacterModel.from_dict(character))

        # Retorna a lista de personagens do usuário.
        return user_characters_list
    else:
        # Se o user_id fornecido não estiver presente no dicionário
        # user_characters
        print("Nenhum personagem encontrado para o usuário")
        return []


# Deleta um personagem da API e atualiza o dicionário de personagens (memória do servidor).
# @param parent: O nó pai ao qual o HTTPRequest será adicionado.
# @param user_id: O ID do usuário ao qual o personagem pertence.
# @param character_id: O ID do personagem a ser deletado.
func delete_character_from_api(parent: Node, user_id: String, character_id: String) -> void:
    # Inicializa uma variável para verificar se o personagem pertence ao usuário.
    var character_belongs_to_user = false

    # Inicializa uma variável para armazenar o índice do personagem no array de personagens do usuário.
    var character_index = -1

    # Verifica se o user_id fornecido está presente no dicionário de personagens.
    if user_id in user_characters:

        # Itera sobre os personagens do usuário.
        for i in range(user_characters[user_id].size()):

            # Se o ID do personagem corresponder ao character_id fornecido,
            # define character_belongs_to_user como true e armazena o índice do personagem.
            if user_characters[user_id][i]["id"] == character_id:
                character_belongs_to_user = true
                character_index = i
                break

    # Se o personagem não pertencer ao usuário, imprime uma mensagem de erro e retorna.
    if not character_belongs_to_user:
        print("Erro: O personagem não pertence ao usuário")
        return

    # Define a URL para a solicitação DELETE.
    var url = api_endpoint + "/api/collections/characters/records/" + character_id

    # Define os cabeçalhos da requisição com o token necessário para a api validar.
    var headers_dict = {"Content-Type": "application/json", "token": api_token}

    # Cria um novo objeto HTTPRequest e adiciona-o ao nó pai.
    var http_request = HTTPRequest.new()
    parent.add_child(http_request)

    # Converte o dicionário de cabeçalhos em um PackedStringArray.
    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    # Envia a solicitação DELETE para a API.
    http_request.request(url, headers, HTTPClient.METHOD_DELETE)

    # Aguarda a conclusão da solicitação DELETE.
    var data = await http_request.request_completed as Array

    # Se a solicitação DELETE falhar, imprime uma mensagem de erro e retorna.
    if data[0] != OK:
        print("Erro ao iniciar a solicitação HTTP: ", data[0])
        return
    else:
        # Se a solicitação DELETE for bem-sucedida, remove o personagem do
        # dicionário de personagens.
        print("Personagem deletado com sucesso: ", character_id)
        http_request.queue_free()
        user_characters[user_id].erase(character_index)



# Cria um novo personagem na API e atualiza o dicionário de personagens (memória do servidor).
# @param parent: O nó pai ao qual o HTTPRequest será adicionado.
# @param user_id: O ID do usuário que está criando o personagem.
# @param character_name: O nome do personagem a ser criado.
func create_character_on_api(parent: Node, user_id: String, character_name: String) -> Dictionary:

    print("api: " + user_id)

    # Cria um novo objeto RegEx e compila uma expressão regular que só permite letras e números.
    var regex = RegEx.new()
    regex.compile("^[a-zA-Z0-9]*$")

     # Verifica se o nome do personagem fornecido é válido.
    if not regex.search(character_name):
        print("Erro: O nome do personagem só pode conter letras e números")
        return CharacterModel.clean().to_dict()

    # Verifica se já existe um personagem com o mesmo nome.
    for uid in user_characters:
        for character in user_characters[uid]:
            if character["name"].to_lower() == character_name.to_lower():
                print("Erro: Já existe um personagem com o mesmo nome")
                return CharacterModel.clean().to_dict()

    # Define a URL para a solicitação POST.
    var url = api_endpoint + "/api/collections/characters/records"

    # Define os cabeçalhos da requisição com o token necessário para a api validar.
    var headers_dict = {"Content-Type": "application/json", "token": api_token}

    # Cria um novo objeto HTTPRequest e adiciona-o ao nó pai.
    var http_request = HTTPRequest.new()
    parent.add_child(http_request)

    # Converte o dicionário de cabeçalhos em um PackedStringArray.
    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    # Cria um novo objeto CharacterModel com os dados do personagem fornecidos.
    var character = CharacterModel.new("", "", "", "", character_name, "", user_id)

    # Converte o objeto CharacterModel em um dicionário.
    var character_data = character.to_dict()

    # Converte o dicionário de dados do personagem em uma string JSON.
    var body = JSON.stringify(character_data)

    # Envia a solicitação POST para a API.
    http_request.request(url, headers, HTTPClient.METHOD_POST, body)

    # Aguarda a conclusão da solicitação POST.
    var data = await http_request.request_completed as Array

    # Se a solicitação POST falhar, imprime uma mensagem de erro e retorna um
    # dicionário de personagem vazio.
    if data[0] != OK:
        print("Erro ao iniciar a solicitação HTTP: ", data[0])
        return CharacterModel.clean().to_dict()
    else:
        # Se a solicitação POST for bem-sucedida, imprime uma mensagem de sucesso
        # e adiciona o personagem ao dicionário de personagens.
        var response_body = (data[3] as PackedByteArray).get_string_from_utf8()
        var response = JSON.parse_string(response_body)

        if data[1] == 200:
            print("Personagem criado com sucesso: ", response["id"])
            http_request.queue_free()

            var created_character = CharacterModel.from_dict(response)
            if user_id in user_characters:
                user_characters[user_id].append(created_character.to_dict())
            else:
                user_characters[user_id] = [created_character.to_dict()]

            return created_character.to_dict()

        elif data[1] == 400 or data[1] == 403:
            var error = ErrorModel.from_dict(JSON.parse_string(response_body))
            var detailed_message = "Falha ao criar o registro: " + error.message
            if error.data.has("message"):
                detailed_message += "\n" + error.data["message"]
            print(detailed_message)
            return CharacterModel.clean().to_dict()

    return CharacterModel.clean().to_dict()
