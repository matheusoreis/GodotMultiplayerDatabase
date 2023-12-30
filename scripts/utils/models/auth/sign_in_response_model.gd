extends RefCounted

class_name SignInResponseModel

var token: String
var record: RecordModel

static func from_dict(dict: Dictionary) -> SignInResponseModel:
    var model = SignInResponseModel.new()
    model.token = dict["token"]
    model.record = RecordModel.from_dict(dict["record"])
    return model

func to_dict() -> Dictionary:
    return {
        "token": token,
        "record": record.to_dict()
    }
