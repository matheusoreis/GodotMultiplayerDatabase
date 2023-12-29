extends RefCounted

class_name SignInModel
var email: String
var password: String

func _init(_email : String, _password : String):
    email = _email
    password = _password

func to_dict() -> Dictionary:
    return {
        "identity": email,
        "password": password
    }

static func from_dict(dict: Dictionary) -> SignInModel:
    var model = SignInModel.new(dict["identity"], dict["password"])
    return model
