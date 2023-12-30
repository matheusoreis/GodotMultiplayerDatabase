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

static func from_dict(dict: Dictionary) -> RecordModel:
    var model = RecordModel.new()
    model.id = dict["id"]
    model.collectionId = dict["collectionId"]
    model.collectionName = dict["collectionName"]
    model.username = dict["username"]
    model.verified = dict["verified"]
    model.emailVisibility = dict["emailVisibility"]
    model.email = dict["email"]
    model.created = dict["created"]
    model.updated = dict["updated"]
    return model

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
