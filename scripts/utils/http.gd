extends Node

var http_request : HTTPRequest

func _init():
    http_request = HTTPRequest.new()
    self.add_child(http_request)

signal request_completed(status: String, response: String, method: int)

func post_request(url: String, headers: Dictionary = {}, body: String = "") -> void:
    _request(url, HTTPClient.METHOD_POST, headers, body)

func get_request(url: String, headers: Dictionary = {}) -> void:
    _request(url, HTTPClient.METHOD_GET, headers)

func put_request(url: String, headers: Dictionary = {}, body: String = "") -> void:
    _request(url, HTTPClient.METHOD_PUT, headers, body)

func delete_request(url: String, headers: Dictionary = {}) -> void:
    _request(url, HTTPClient.METHOD_DELETE, headers)

func _request(url: String, method: int, headers: Dictionary, body: String = "") -> void:
    var req: HTTPRequest = HTTPRequest.new()
    self.add_child(req)

    var packed_headers: PackedStringArray = PackedStringArray()
    for key in headers.keys():
        packed_headers.append('%s: %s' % [key, headers[key]])

    req.request(url, packed_headers, method, body)
    req.request_completed.connect(func(_result, _response_code, _headers, _body) : _on_request_completed(_result, _response_code, _headers, _body, method))

func _on_request_completed(result, response_code, _headers, body, method):
    var status = "error"
    var response_body = body.get_string_from_utf8()

    if result == OK and response_code == 200:
        status = "success"

    emit_signal("request_completed", status, response_body, method)
