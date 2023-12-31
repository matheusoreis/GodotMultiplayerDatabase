extends RefCounted

class_name CharacterModel

var collectionId: String
var collectionName: String
var created: String
var id: String
var name: String
var updated: String
var user: String

func _init(_collectionId : String = "", _collectionName : String = "", _created : String = "", _id : String = "", _name : String = "", _updated : String = "", _user : String = ""):
    collectionId = _collectionId
    collectionName = _collectionName
    created = _created
    id = _id
    name = _name
    updated = _updated
    user = _user

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


static func from_dict(dict: Dictionary) -> CharacterModel:
    var model = CharacterModel.new(dict["collectionId"], dict["collectionName"], dict["created"], dict["id"], dict["name"], dict["updated"], dict["user"])
    return model


static func clean() -> CharacterModel:
    return CharacterModel.new()
