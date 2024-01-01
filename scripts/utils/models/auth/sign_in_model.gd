extends RefCounted


class_name SignInModel
var email: String
var password: String


# Função de inicialização para a classe SignInModel
func _init(_email : String = "", _password : String = ""):
    email = _email
    password = _password


# Função para converter o objeto SignInModel em um dicionário
func to_dict() -> Dictionary:
    return {
        "identity": email,
        "password": password
    }


# Função estática para criar um objeto SignInModel a partir de um dicionário
static func from_dict(dict: Dictionary) -> SignInModel:
    var model = SignInModel.new(dict["identity"], dict["password"]) as SignInModel
    return model


# Função estática para criar um objeto SignInModel vazio
static func clean() -> SignInModel:
    return SignInModel.new()
