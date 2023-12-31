extends Control


class_name CharacterDataLoader


@export var api_endpoint : String = 'http://127.0.0.1:8090'


var user_characters = {}
var timer


func initialize(parent):
    await fetch_characters_from_api(parent)


func fetch_characters_from_api(parent):
    var url = api_endpoint + "/api/collections/characters/records"
    var headers_dict = {"Content-Type": "application/json", "token": "ajshdwuqyezbxcbvzxbcvqytuqweyt"}

    var http_request = HTTPRequest.new()
    parent.add_child(http_request)


    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    var page = 1
    var total_pages = 1
    while page <= total_pages:
        http_request.request(url + "?page=" + str(page), headers, HTTPClient.METHOD_GET)
        var data = await http_request.request_completed as Array
        if data[0] != OK:
            print("Erro ao iniciar a solicitação HTTP: ", data[0])
            return
        else:
            var response_body = (data[3] as PackedByteArray).get_string_from_utf8()
            print("Resposta da API: ", response_body)
            var response = JSON.parse_string(response_body)

            var items = response["items"]

            for item in items:
                var character = CharacterModel.from_dict(item)
                var user_id = character.user

                print("Personagem: ", character.to_dict())

                if user_id in user_characters:
                    user_characters[user_id].append(character.to_dict())
                else:
                    user_characters[user_id] = [character.to_dict()]

            print("User IDs após carregar personagens: ", user_characters.keys())

            total_pages = response["totalPages"]
            page += 1


func get_characters_for_user(user_id: String) -> Array:
    print("User ID fornecido: ", user_id)  # Imprime o user_id fornecido
    print("User IDs nos dados: ", user_characters.keys())  # Imprime os user_id's nos dados

    if user_id in user_characters:
        var user_characters_list = []
        var characters_pending_deletion = []

        for character in user_characters[user_id]:
            # Verifica se o personagem está na lista de exclusões pendentes
            var is_pending_deletion = characters_pending_deletion.find(character["id"]) != -1

            if not is_pending_deletion:
                user_characters_list.append(CharacterModel.from_dict(character))

        return user_characters_list
    else:
        print("Nenhum personagem encontrado para o usuário")
        return []


func delete_character_from_api(parent, user_id: String, character_id: String) -> void:
    var character_belongs_to_user = false
    var character_index = -1
    if user_id in user_characters:
        for i in range(user_characters[user_id].size()):
            if user_characters[user_id][i]["id"] == character_id:
                character_belongs_to_user = true
                character_index = i
                break

    if not character_belongs_to_user:
        print("Erro: O personagem não pertence ao usuário")
        return

    var url = api_endpoint + "/api/collections/characters/records/" + character_id
    var headers_dict = {"Content-Type": "application/json", "token": "ajshdwuqyezbxcbvzxbcvqytuqweyt"}

    var http_request = HTTPRequest.new()
    parent.add_child(http_request)

    var headers = PackedStringArray()
    for key in headers_dict:
        headers.append('%s: %s' % [key, headers_dict[key]])

    http_request.request(url, headers, HTTPClient.METHOD_DELETE)
    var data = await http_request.request_completed as Array
    if data[0] != OK:
        print("Erro ao iniciar a solicitação HTTP: ", data[0])
        return
    else:
        print("Personagem deletado com sucesso: ", character_id)
        http_request.queue_free()

        user_characters[user_id].erase(character_index)
