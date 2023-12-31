extends Control

@export_category('UI')
@export var server_ui : Control
@export var character_ui : Control

@export_category('Character Panel')
@export var character_panel: PanelContainer
@export var character_hbox: HBoxContainer

@export_category('New Character Panel')
@export var new_character_panel: PanelContainer
@export var new_character_name_line: LineEdit
@export var new_character_button: Button

@export_category('Character Slot')
@export var character_slot_ui = preload('res://scenes/components/character_slot_ui.tscn')


var user_id : String
var received_characters : Array = []


# Esta função é usada para definir o ID do usuário
func set_user_id(userId: String) -> void:
    # Atribui o valor de id à variável de instância user_id
    self.user_id = userId


# Esta função é chamada quando a visibilidade do nó é alterada
func _on_visibility_changed() -> void:
    if visible:
        # Faz uma chamada de procedimento remoto (RPC) para solicitar os personagens do usuário
        server_ui.request_characters.rpc_id(1, user_id)


# Esta função é chamada para confirmar a exclusão de um personagem
@rpc("authority","reliable")
func confirm_delete_character(characterDict: Dictionary) -> void:
    var character_to_delete = CharacterModel.from_dict(characterDict) as CharacterModel
    # Itera sobre a lista de personagens recebidos
    for i in range(received_characters.size()):
        # Se o personagem na lista corresponder ao personagem a ser excluído
        if received_characters[i].id == character_to_delete.id:
            # Remove o personagem da lista
            received_characters.remove_at(i)
            break

    # Atualiza os botões com a lista de personagens atualizada
    update_buttons(received_characters)


# Esta função é chamada para confirmar a criação de um novo personagem.
@rpc("authority","reliable")
func confirm_create_character(characterDict: Dictionary) -> void:
    var new_character = CharacterModel.from_dict(characterDict) as CharacterModel

    # Verifica se o dicionário do novo personagem está vazio ou se o ID do personagem está vazio
    if characterDict.is_empty() or new_character.id == "":
        # Se estiver vazio, imprime uma mensagem de erro e retorna
        print("O dicionário do novo personagem está vazio ou o ID do personagem está vazio.")
        return

     # Torna o painel de personagem visível e o painel de novo personagem invisível
    character_panel.visible = true
    new_character_panel.visible = false

    # Adiciona o novo personagem à lista de personagens recebidos
    received_characters.append(characterDict)

    # Atualiza os botões com a lista de personagens atualizada
    update_buttons(received_characters)


# Função chamada para receber os personagens do servidor
@rpc("authority","reliable")
func receive_characters(characters: Array) -> void:
    # Limpa a lista atual de personagens recebidos
    received_characters.clear()

    # Itera sobre cada dicionário de personagem na matriz recebida
    for character_dict in characters:
        # Adiciona o dicionário do personagem à lista de personagens recebidos
        received_characters.append(character_dict)

    # Atualiza os botões com a lista de personagens atualizada
    update_buttons(received_characters)


# Esta função cria um slot de personagem na interface do usuário
func create_character_slot(index: int, characterDict: Dictionary = {}) -> void:
    # Instancia um novo slot de personagem
    var character_slot = character_slot_ui.instantiate()

    # Define o nome do slot para o índice passado como parâmetro
    character_slot.name = str(index)

    # Obtém componentes do slot instânciado
    var character_slot_label = character_slot.get_node("CharacterLabel") as Label
    var access_character_slot_button = character_slot.get_node("CharacterAccessButton") as Button
    var delete_character_slot_button = character_slot.get_node("CharacterDeleteButton") as Button

    # Se o dicionário do personagem estiver vazio
    if characterDict.is_empty():
        character_slot_label.text = "Novo Personagem"
        delete_character_slot_button.disabled = true
        access_character_slot_button.text = "Criar"

        # Conecta o sinal de pressionado do botão de acesso à função _on_character_create_button_pressed
        access_character_slot_button.pressed.connect(_on_character_create_button_pressed)
    else:
        delete_character_slot_button.disabled = false
        var character_model = CharacterModel.from_dict(characterDict) as CharacterModel
        character_slot_label.text = character_model.name

        # Conecta o sinal de pressionado do botão de exclusão à função _on_character_delete_button_pressed
        delete_character_slot_button.pressed.connect(_on_character_delete_button_pressed.bind(character_slot, user_id, characterDict))

    # Adiciona o slot de personagem como um filho do contêiner HBox
    character_hbox.add_child(character_slot)


# Esta função cria slots para cada personagem na lista de personagens.
func create_slots(characters: Array) -> void:
    # Para cada personagem na lista de personagens
    for i in range(characters.size()):
        create_character_slot(i, characters[i])

    # Se o número de personagens for menor que 3
    if characters.size() < 3:
        create_character_slot(characters.size())


# Esta função atualiza os slots de personagem na interface do usuário.
func update_buttons(characters: Array) -> void:
    # Para cada slot de personagem existente
    for child in character_hbox.get_children():
        child.queue_free()

    # Cria novos slots de personagem com base na lista atualizada de personagens
    create_slots(characters)


# Esta função é chamada quando o botão de exclusão de um slot de personagem é pressionado.
func _on_character_delete_button_pressed(characterSlot: VBoxContainer, userId: String, characterDict: Dictionary) -> void:
    # Armazena o nó UI do slot de personagem selecionado em uma variável
    var character_slot = characterSlot

    # Inicializa um novo dicionário para o personagem
    var character_dict = {}

    # Itera sobre a lista de personagens recebidos
    for character in received_characters:
        # Se o dicionário do personagem corresponder ao dicionário do personagem selecionado
        if character == characterDict:
            # Atribui o dicionário do personagem ao character_dict
            character_dict = character
            break

    # Faz uma chamada RPC para solicitar a exclusão do personagem
    server_ui.request_delete_character.rpc_id(1, userId, character_dict)

    # Remove o slot de personagem da interface do usuário
    character_slot.queue_free()


# Esta função é chamada quando o botão de criação de um novo personagem é pressionado.
func _on_character_create_button_pressed() -> void:
    # Torna o painel de novo personagem visível
    new_character_panel.visible = true

    # Esconde o painel de personagem
    character_panel.visible = false


# Esta função é chamada quando o botão de novo personagem é pressionado.
func _on_new_character_button_pressed() -> void:
    # Faz uma chamada RPC para solicitar a criação de um novo personagem
    server_ui.request_create_character.rpc_id(1, user_id, new_character_name_line.text)
