extends Control


class_name CharacterDataLoader


@export var api_endpoint : String = 'http://127.0.0.1:8090'


var user_characters = {}
var characters_to_delete = []
var timer


var parent_node

func initialize(parent):
    parent_node = parent
    await fetch_characters_from_api(parent)
    timer = Timer.new()
    timer.set_wait_time(10)  # 300 segundos = 5 minutos
    timer.set_one_shot(false)
    timer.connect("timeout",  _on_Timer_timeout)
    parent.add_child(timer)
    timer.start()


func _on_Timer_timeout() -> void:
    print("Tempo limite do temporizador atingido.")

    if not characters_to_delete:
        print("Nenhum personagem para excluir.")
        return

    var characters_to_keep := []

    for i in range(characters_to_delete.size() - 1, -1, -1):
        var character = characters_to_delete[i]
        delete_character_from_api(parent_node, character["user_id"], character["character_id"])
        characters_to_delete.erase(i)

    characters_to_delete = characters_to_keep


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
            print("Resposta da API: ", response_body)  # Imprime a resposta da API
            var response = JSON.parse_string(response_body)

            var items = response["items"]

            for item in items:
                var character = CharacterModel.from_dict(item)
                var user_id = character.user

                print("Personagem: ", character.to_dict())  # Imprime o personagem

                if user_id in user_characters:
                    user_characters[user_id].append(character.to_dict())
                else:
                    user_characters[user_id] = [character.to_dict()]

            print("User IDs após carregar personagens: ", user_characters.keys())  # Imprime os user_id's após carregar os personagens

            total_pages = response["totalPages"]
            page += 1


func get_characters_for_user(user_id: String) -> Array:
    print("User ID fornecido: ", user_id)  # Imprime o user_id fornecido
    print("User IDs nos dados: ", user_characters.keys())  # Imprime os user_id's nos dados
    if user_id in user_characters:
        var user_characters_list = []
        for character in user_characters[user_id]:
            # Verifica se o personagem está na lista de exclusões pendentes
            var is_pending_deletion = false
            for deleted_character in characters_to_delete:
                if deleted_character["user_id"] == user_id and deleted_character["character_id"] == character["id"]:
                    is_pending_deletion = true
                    break
            # Se o personagem não está na lista de exclusões pendentes, adiciona à lista de personagens do usuário
            if not is_pending_deletion:
                user_characters_list.append(CharacterModel.from_dict(character))
        return user_characters_list
    else:
        print("Nenhum personagem encontrado para o usuário")
        return []


#func create_character(user_id: String, character: CharacterModel) -> void:
    #pass

func delete_character(user_id: String, character_id: String) -> void:
    # Remove o personagem da memória
    if user_id in user_characters:
        var temp_characters = user_characters[user_id].duplicate()
        for i in range(len(temp_characters)):
            if temp_characters[i]["id"] == character_id:
                user_characters[user_id].erase(i)
                print("Personagem deletado: ", character_id)
                break

    # Adiciona o personagem à lista de exclusões pendentes
    characters_to_delete.append({ "user_id": user_id, "character_id": character_id })


func delete_character_from_api(parent, user_id: String, character_id: String) -> void:
    # Verifica se o personagem pertence ao usuário
    var character_belongs_to_user = false
    if user_id in user_characters:
        for character in user_characters[user_id]:
            if character["id"] == character_id:
                character_belongs_to_user = true
                break

    if not character_belongs_to_user:
        print("Erro: O personagem não pertence ao usuário")
        return

    var url = api_endpoint + "/api/collections/characters/records/" + character_id
    var headers_dict = {"Content-Type": "application/json", "token": "ajshdwuqyezbxcbvzxbcvqytuqweyt"}

    var http_request = HTTPRequest.new()
    parent.add_child(http_request)  # Adiciona o objeto HTTPRequest à árvore de cena

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

