extends Control


class_name CharacterDataLoader


@export var api_endpoint : String = 'http://127.0.0.1:8090'


var CharacterModelLocal : Script = preload("res://scripts/utils/models/database/character_model.gd")


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
            var response = JSON.parse_string(response_body)

            var items = response["items"]
            var characters = []
            for item in items:
                var character = CharacterModel.from_dict(item)
                characters.append(character.to_dict())

            var file = FileAccess.open("user://characters.json", FileAccess.WRITE)
            file.store_string(JSON.stringify(characters))
            file.close()

            total_pages = response["totalPages"]
            page += 1

func get_characters_for_user(user_id: String) -> Array:
    var file = FileAccess.open("user://characters.json", FileAccess.READ)
    if not file:
        print("Falha ao abrir o arquivo")
        return []

    var content = file.get_as_text()
    file.close()

    var characters = JSON.parse_string(content)
    var user_characters = []
    for character in characters:
        if character["user"] == user_id:
            user_characters.append(CharacterModel.from_dict(character))

    return user_characters
