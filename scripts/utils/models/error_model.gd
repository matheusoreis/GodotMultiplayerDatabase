extends RefCounted


class_name ErrorModel


var code: int
var message: String
var data: Dictionary


func _init(_code : int = 0, _message : String = "", _data : Dictionary = {}):
    code = _code
    message = _message
    data = _data


static func from_dict(dict: Dictionary) -> ErrorModel:
    var model = ErrorModel.new(dict["code"], dict["message"], dict["data"])
    return model


func to_dict() -> Dictionary:
    return {
        "code": code,
        "message": message,
        "data": data
    }


static func clean() -> ErrorModel:
    return ErrorModel.new()
