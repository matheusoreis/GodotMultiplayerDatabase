extends RefCounted

class_name SignInResponseModel

var record: RecordModel
var token: String

static func from_dict(dict: Dictionary) -> SignInResponseModel:
    var model = SignInResponseModel.new()

    if dict.has("record"):
        model.record = RecordModel.from_dict(dict["record"])
    else:
        print("O dicionário não contém a chave 'record'")

    if dict.has("token"):
        model.token = dict["token"]
    else:
        print("O dicionário não contém a chave 'token'")

    return model

func to_dict() -> Dictionary:
    return {
        "record": record.to_dict(),
        "token": token
    }
