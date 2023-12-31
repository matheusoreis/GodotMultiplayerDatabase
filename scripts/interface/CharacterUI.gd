extends Control

@export var character_ui : Control
@export var server_ui : Control

@export var character_hbox: HBoxContainer
@export var character_panel: PanelContainer
@export var new_character_panel: PanelContainer
@export var new_character_name_line: LineEdit
@export var new_character_button: Button

@export var character_select_ui = preload('res://scenes/components/character_select.tscn')


var user_id : String
var received_characters : Array = []


func set_user_id(user: String) -> void:
    print(user)
    self.user_id = user
    print(user_id)


func _on_visibility_changed() -> void:
    print('user: ' + user_id)
    if visible:
        server_ui.request_characters.rpc_id(1, user_id)


@rpc("authority","reliable")
func send_characters(character_dicts: Array):
    for character_dict in character_dicts:
        var character = CharacterModel.from_dict(character_dict)
        print("Personagem: ", character.name)


@rpc("authority","reliable")
func confirm_delete_character(_character_id: String) -> void:
    for i in range(received_characters.size()):
        if received_characters[i]["id"] == _character_id:
            received_characters.remove_at(i)
            break

    update_buttons(received_characters)


@rpc("authority","reliable")
func confirm_create_character(new_character_dict: Dictionary) -> void:
    if new_character_dict.is_empty():
        print("O dicionário do novo personagem está vazio.")
        return

    character_panel.visible = true
    new_character_panel.visible = false
    received_characters.append(new_character_dict)

    update_buttons(received_characters)


@rpc("authority","reliable")
func receive_characters(character_dicts: Array) -> void:
    received_characters.clear()

    for character_dict in character_dicts:
        received_characters.append(character_dict)

    update_buttons(received_characters)


func create_buttons(characters: Array) -> void:
    for i in range(characters.size()):
        var character_select = character_select_ui.instantiate()
        character_select.name = str(i)

        var select_character_label = character_select.get_node("CharacterLabel") as Label
        var access_character_button = character_select.get_node("CharacterAccessButton") as Button
        var delete_character_button = character_select.get_node("CharacterDeleteButton") as Button

        var character = CharacterModel.from_dict(characters[i])
        select_character_label.text = character.name
        delete_character_button.pressed.connect(_on_character_delete_button_pressed.bind(character_select, user_id, character.id))

        character_hbox.add_child(character_select)

    if characters.size() < 3:
        var character_select = character_select_ui.instantiate()
        character_select.name = str(characters.size())

        var select_character_label = character_select.get_node("CharacterLabel") as Label
        var access_character_button = character_select.get_node("CharacterAccessButton") as Button
        var delete_character_button = character_select.get_node("CharacterDeleteButton") as Button

        select_character_label.text = "Novo Personagem"
        delete_character_button.hide()
        access_character_button.text = "Criar"
        access_character_button.pressed.connect(_on_character_create_button_pressed)

        character_hbox.add_child(character_select)


func update_buttons(characters: Array) -> void:
    for child in character_hbox.get_children():
        child.queue_free()

    create_buttons(characters)


func _on_character_delete_button_pressed(character_selected_ui: VBoxContainer, user_selected_id: String, character_selected_id: String) -> void:
    var character_select = character_selected_ui
    server_ui.request_delete_character.rpc_id(1, user_selected_id, character_selected_id)
    character_select.queue_free()


func _on_character_create_button_pressed() -> void:
    print('clicou')
    new_character_panel.visible = true
    character_panel.visible = false


func _on_new_character_button_pressed() -> void:
     server_ui.request_create_character.rpc_id(1, user_id, new_character_name_line.text)
