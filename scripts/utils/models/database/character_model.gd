extends RefCounted

class_name CharacterModel

var collectionId: String
var collectionName: String
var created: String
var id: String
var name: String
var updated: String
var user: String


# Função de inicialização para a classe CharacterModel
func _init(_collectionId : String = "", _collectionName : String = "", _created : String = "", _id : String = "", _name : String = "", _updated : String = "", _user : String = ""):
    # Inicializa as variáveis da classe com os valores passados como argumentos
    collectionId = _collectionId
    collectionName = _collectionName
    created = _created
    id = _id
    name = _name
    updated = _updated
    user = _user


# Função para converter o objeto CharacterModel em um dicionário
func to_dict() -> Dictionary:
    return {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created,
        "id": id,
        "name": name,
        "updated": updated,
        "user": user
    }


# Função estática para criar um objeto CharacterModel a partir de um dicionário
static func from_dict(dict: Dictionary) -> CharacterModel:
    var model = CharacterModel.new(
        dict["collectionId"],
        dict["collectionName"],
        dict["created"], dict["id"],
        dict["name"],
        dict["updated"],
        dict["user"]
    ) as CharacterModel

    return model


# Função estática para criar um objeto CharacterModel vazio
static func clean() -> CharacterModel:
    return CharacterModel.new()
