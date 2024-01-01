extends RefCounted


class_name RecordModel


var id: String
var collectionId: String
var collectionName: String
var username: String
var verified: bool
var emailVisibility: bool
var email: String
var created: String
var updated: String


# Função de inicialização para a classe RecordModel
func _init(_id : String = "", _collectionId : String = "", _collectionName : String = "", _username : String = "", _verified : bool = false, _emailVisibility : bool = false, _email : String = "", _created : String = "", _updated : String = ""):
    id = _id
    collectionId = _collectionId
    collectionName = _collectionName
    username = _username
    verified = _verified
    emailVisibility = _emailVisibility
    email = _email
    created = _created
    updated = _updated


# Função estática para criar um objeto RecordModel a partir de um dicionário
static func from_dict(dict: Dictionary) -> RecordModel:
    var model = RecordModel.new(
        dict["id"],
        dict["collectionId"],
        dict["collectionName"],
        dict["username"],
        dict["verified"],
        dict["emailVisibility"],
        dict["email"],
        dict["created"],
        dict["updated"]
    ) as RecordModel

    return model


# Função para converter o objeto RecordModel em um dicionário
func to_dict() -> Dictionary:
    return {
        "id": id,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "username": username,
        "verified": verified,
        "emailVisibility": emailVisibility,
        "email": email,
        "created": created,
        "updated": updated
    }


# Função estática para criar um objeto RecordModel vazio
static func clean() -> RecordModel:
    return RecordModel.new()
