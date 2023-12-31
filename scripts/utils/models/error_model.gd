extends RefCounted

class_name ErrorModel

var status_code: int
var message: String
var data: Dictionary

static func from_dict(dict: Dictionary) -> ErrorModel:
    var model = ErrorModel.new()
    model.status_code = dict["status_code"]
    model.message = dict["message"]
    model.data = dict["data"]
    return model

func to_dict() -> Dictionary:
    return {
        "status_code": status_code,
        "message": message,
        "data": data
    }
