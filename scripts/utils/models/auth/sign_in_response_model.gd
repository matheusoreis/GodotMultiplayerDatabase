extends RefCounted


class_name SignInResponseModel


var record: RecordModel
var token: String


# Função de inicialização para a classe SignInResponseModel
func _init(_record : RecordModel = null, _token : String = ""):
    record = _record
    token = _token


# Função estática para criar um objeto SignInResponseModel a partir de um dicionário
static func from_dict(dict: Dictionary) -> SignInResponseModel:
    var model = SignInResponseModel.new(RecordModel.from_dict(dict["record"]), dict["token"]) as SignInResponseModel
    return model


# Função para converter o objeto SignInResponseModel em um dicionário
func to_dict() -> Dictionary:
    return {
        "record": record.to_dict(),
        "token": token
    }


# Função estática para criar um objeto SignInResponseModel vazio
static func clean() -> SignInResponseModel:
    return SignInResponseModel.new() as SignInResponseModel
