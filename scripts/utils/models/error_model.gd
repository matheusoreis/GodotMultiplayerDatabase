extends RefCounted


class_name ErrorModel


var code: int
var message: String
var data: Dictionary


# Função de inicialização para a classe ErrorModel
func _init(_code : int = 0, _message : String = "", _data : Dictionary = {}):
    code = _code
    message = _message
    data = _data


# Função estática para criar um objeto ErrorModel a partir de um dicionário
static func from_dict(dict: Dictionary) -> ErrorModel:
    var model = ErrorModel.new(dict["code"], dict["message"], dict["data"]) as ErrorModel
    return model


# Função para converter o objeto ErrorModel em um dicionário
func to_dict() -> Dictionary:
    return {
        "code": code,
        "message": message,
        "data": data
    }


# Função estática para criar um objeto ErrorModel vazio
static func clean() -> ErrorModel:
    return ErrorModel.new() as ErrorModel
